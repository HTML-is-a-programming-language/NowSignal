Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$VerifierId = 'gate2-offline-evidence-verifier-v1'
$ExpectedRun9ScriptSha256 = '5076e413770b501e767145834412b1679fcf28de780721995125b69ffae2b5e5'
$ExpectedErrorClassifierSha256 = '7e22b789df47f699492ab4aa7d4d0771f677ca3175f80b4efa5e7e833f991c24'
$ExpectedEvidenceHashes = [ordered]@{
    'plan-v6' = 'd270545f6b95161ae72bbf681bfdc4fa9c5ce3ddc4a8265ed6ec2a2b39a75d2e'
    'manifest-r6' = '93f814f3613a6afad82243b01a17cec36b199065e9f711704b9b9fad3fd0d68f'
    'plan-v7' = 'c49c9dc18a9af71ac16b64278d47c359bc978d60924d7ac594a885f3cb80b268'
    'manifest-r7' = '959dc9086f1a1e9398a670d622310721adb30fc66e963dfd81b5725d3b657c03'
    'plan-v8' = '35cb9bdeb0d3531a4f0ce63673eca385f384d80804e9e95df8cb93aab32b9c20'
    'manifest-r8' = 'dc6c61a2488f97dda6975aec43bfe1b6bfc4f4e08ee20277ab5cddd5938d085f'
    'plan-v9' = 'd3eb18ad5cd364d1515acd74fd94fe43ba87f3ff012172264290d588d905715b'
    'manifest-r9' = '732775583ff2b3917b3d8ce5f7076238475ebc0a2aa46354e458c6ec9985bdf2'
}

function Get-BytesSha256 {
    param([Parameter(Mandatory = $true)][byte[]]$Bytes)

    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha.ComputeHash($Bytes)
        return ([BitConverter]::ToString($hash)).Replace('-', '').ToLowerInvariant()
    }
    finally {
        if ($null -ne $sha) {
            $sha.Dispose()
        }
    }
}

function Get-TextSha256 {
    param([Parameter(Mandatory = $true)][string]$Text)

    $encoding = New-Object Text.UTF8Encoding($false)
    return Get-BytesSha256 -Bytes $encoding.GetBytes($Text)
}

function Get-FileSha256 {
    param([Parameter(Mandatory = $true)][string]$Path)

    return Get-BytesSha256 -Bytes ([IO.File]::ReadAllBytes($Path))
}

function Get-ScriptAstAudit {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][int]$ExpectedGetResponseSites
    )

    $tokens = $null
    $parseErrors = $null
    $ast = [Management.Automation.Language.Parser]::ParseFile(
        $Path,
        [ref]$tokens,
        [ref]$parseErrors
    )

    $commands = @(
        $ast.FindAll(
            { param($node) $node -is [Management.Automation.Language.CommandAst] },
            $true
        ) | ForEach-Object { $_.GetCommandName() }
    )
    $dynamicCommandCount = @(
        $commands | Where-Object { [string]::IsNullOrWhiteSpace($_) }
    ).Count

    $denyCommands = @(
        'Invoke-WebRequest',
        'Invoke-RestMethod',
        'Start-BitsTransfer',
        'Set-Content',
        'Add-Content',
        'Out-File',
        'Export-Clixml',
        'Export-Csv',
        'Tee-Object'
    )
    $deniedCommandCount = @(
        $commands | Where-Object { $denyCommands -contains $_ }
    ).Count

    $memberCalls = @(
        $ast.FindAll(
            { param($node) $node -is [Management.Automation.Language.InvokeMemberExpressionAst] },
            $true
        )
    )
    $getResponseSites = @(
        $memberCalls | Where-Object { $_.Member.Value -eq 'GetResponse' }
    )
    $getResponseInsideLoopCount = 0
    foreach ($site in $getResponseSites) {
        $parent = $site.Parent
        while ($null -ne $parent) {
            if (
                $parent -is [Management.Automation.Language.ForStatementAst] -or
                $parent -is [Management.Automation.Language.ForEachStatementAst] -or
                $parent -is [Management.Automation.Language.WhileStatementAst] -or
                $parent -is [Management.Automation.Language.DoWhileStatementAst] -or
                $parent -is [Management.Automation.Language.DoUntilStatementAst]
            ) {
                $getResponseInsideLoopCount += 1
                break
            }
            $parent = $parent.Parent
        }
    }

    $networkMembers = @(
        'GetResponse',
        'GetResponseAsync',
        'Send',
        'SendAsync',
        'Connect',
        'ConnectAsync',
        'DownloadData',
        'DownloadString',
        'UploadData',
        'UploadString'
    )
    $networkMemberCount = @(
        $memberCalls | Where-Object { $networkMembers -contains $_.Member.Value }
    ).Count

    $pass = (
        $parseErrors.Count -eq 0 -and
        $dynamicCommandCount -eq 0 -and
        $deniedCommandCount -eq 0 -and
        $getResponseSites.Count -eq $ExpectedGetResponseSites -and
        $networkMemberCount -eq $ExpectedGetResponseSites -and
        $getResponseInsideLoopCount -eq 0
    )

    return [pscustomobject][ordered]@{
        parserErrors = $parseErrors.Count
        dynamicCommands = $dynamicCommandCount
        deniedCommands = $deniedCommandCount
        networkMemberSites = $networkMemberCount
        getResponseSites = $getResponseSites.Count
        getResponseInsideLoop = $getResponseInsideLoopCount
        pass = $pass
    }
}

function Invoke-OfflineChild {
    param(
        [Parameter(Mandatory = $true)][string]$PowerShellPath,
        [Parameter(Mandatory = $true)][string]$ScriptPath,
        [string]$ModeArgument
    )

    $startInfo = New-Object Diagnostics.ProcessStartInfo
    $startInfo.FileName = $PowerShellPath
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $ScriptPath + '"'
    if (-not [string]::IsNullOrWhiteSpace($ModeArgument)) {
        $arguments += ' ' + $ModeArgument
    }
    $startInfo.Arguments = $arguments

    $process = New-Object Diagnostics.Process
    $process.StartInfo = $startInfo
    try {
        if (-not $process.Start()) {
            throw New-Object InvalidOperationException('Child process did not start')
        }
        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        return [pscustomobject][ordered]@{
            exitCode = $process.ExitCode
            stdout = $stdout
            stderrLength = $stderr.Length
        }
    }
    finally {
        if ($null -ne $process) {
            $process.Dispose()
        }
    }
}

function Invoke-ChildVersionProbe {
    param([Parameter(Mandatory = $true)][string]$PowerShellPath)

    $startInfo = New-Object Diagnostics.ProcessStartInfo
    $startInfo.FileName = $PowerShellPath
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.Arguments = '-NoProfile -NonInteractive -Command "if ($PSVersionTable.PSVersion.Major -eq 5 -and $PSVersionTable.PSVersion.Minor -eq 1 -and $PSVersionTable.PSEdition -eq ''Desktop'') { [Console]::Out.Write(''5.1|Desktop'') } else { exit 87 }"'

    $process = New-Object Diagnostics.Process
    $process.StartInfo = $startInfo
    try {
        if (-not $process.Start()) {
            throw New-Object InvalidOperationException('Version probe did not start')
        }
        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        return [pscustomobject][ordered]@{
            exitCode = $process.ExitCode
            stdout = $stdout
            stderrLength = $stderr.Length
        }
    }
    finally {
        if ($null -ne $process) {
            $process.Dispose()
        }
    }
}

function Get-EvidenceKey {
    param([Parameter(Mandatory = $true)][pscustomobject]$Object)

    $names = @($Object.PSObject.Properties.Name)
    if ($names -contains 'networkCalls') {
        if ($Object.runId -eq 'contract-smoke-20260810-r6') { return 'manifest-r6' }
        if ($Object.runId -eq 'contract-smoke-20260810-r7') { return 'manifest-r7' }
        if ($Object.runId -eq 'contract-smoke-20260810-r8') { return 'manifest-r8' }
        if ($Object.runId -eq 'contract-smoke-20260810-r9') { return 'manifest-r9' }
        return $null
    }

    if ($Object.planId -eq 'contract-smoke-20260810-v6') { return 'plan-v6' }
    if ($Object.planId -eq 'contract-smoke-20260810-v7') { return 'plan-v7' }
    if ($Object.planId -eq 'contract-smoke-20260810-v8') { return 'plan-v8' }
    if ($Object.planId -eq 'contract-smoke-20260810-v9') { return 'plan-v9' }
    return $null
}

try {
    $repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
    $runbookPath = Join-Path $repoRoot 'docs\provider-validation-runbook.md'
    $run9ScriptPath = Join-Path $repoRoot 'scripts\validation\airkorea-contract-smoke.ps1'
    $classifierPath = Join-Path $repoRoot 'scripts\validation\provider-error-contract-self-test.ps1'

    $verifierScriptSha256 = Get-FileSha256 -Path $PSCommandPath
    $run9ScriptSha256 = Get-FileSha256 -Path $run9ScriptPath
    $classifierSha256 = Get-FileSha256 -Path $classifierPath
    $run9Ast = Get-ScriptAstAudit -Path $run9ScriptPath -ExpectedGetResponseSites 1
    $classifierAst = Get-ScriptAstAudit -Path $classifierPath -ExpectedGetResponseSites 0

    $encoding = New-Object Text.UTF8Encoding($false)
    $runbook = [IO.File]::ReadAllText($runbookPath, $encoding)
    $documentedClassifierHashes = [regex]::Matches(
        $runbook,
        '(?m)^- errorClassifierSha256: `(?<hash>[a-f0-9]{64})`$'
    )
    $documentedVerifierHashes = [regex]::Matches(
        $runbook,
        '(?m)^- offlineVerifierSha256: `(?<hash>[a-f0-9]{64})`$'
    )
    $runbookToolHashPass = (
        $documentedClassifierHashes.Count -eq 1 -and
        $documentedVerifierHashes.Count -eq 1 -and
        $documentedClassifierHashes[0].Groups['hash'].Value -eq $classifierSha256 -and
        $documentedVerifierHashes[0].Groups['hash'].Value -eq $verifierScriptSha256
    )
    $jsonMatches = [regex]::Matches(
        $runbook,
        '(?ms)^```json\r?\n(?<json>\{[^\r\n]+\})\r?\n```'
    )
    $evidence = @{}
    $duplicateEvidence = 0
    $invalidCanonicalJson = 0

    foreach ($match in $jsonMatches) {
        $rawJson = $match.Groups['json'].Value
        try {
            $object = $rawJson | ConvertFrom-Json
            $key = Get-EvidenceKey -Object $object
            if ($null -ne $key) {
                if ($evidence.ContainsKey($key)) {
                    $duplicateEvidence += 1
                }
                else {
                    $evidence[$key] = [pscustomobject][ordered]@{
                        raw = $rawJson
                        sha256 = Get-TextSha256 -Text $rawJson
                        object = $object
                    }
                }
            }
        }
        catch {
            $invalidCanonicalJson += 1
        }
    }

    $evidenceHashPass = ($evidence.Count -eq $ExpectedEvidenceHashes.Count)
    foreach ($key in $ExpectedEvidenceHashes.Keys) {
        if (-not $evidence.ContainsKey($key)) {
            $evidenceHashPass = $false
        }
        elseif ($evidence[$key].sha256 -ne $ExpectedEvidenceHashes[$key]) {
            $evidenceHashPass = $false
        }
    }

    $parentChainPass = (
        $evidence.ContainsKey('plan-v6') -and
        $evidence.ContainsKey('manifest-r6') -and
        $evidence.ContainsKey('plan-v7') -and
        $evidence.ContainsKey('manifest-r7') -and
        $evidence.ContainsKey('plan-v8') -and
        $evidence.ContainsKey('manifest-r8') -and
        $evidence.ContainsKey('plan-v9') -and
        $evidence.ContainsKey('manifest-r9')
    )

    if ($parentChainPass) {
        $parentChainPass = (
            $evidence['manifest-r6'].object.planSha256 -eq $evidence['plan-v6'].sha256 -and
            $evidence['plan-v7'].object.parentPlanSha256 -eq $evidence['plan-v6'].sha256 -and
            $evidence['plan-v7'].object.parentManifestSha256 -eq $evidence['manifest-r6'].sha256 -and
            $evidence['manifest-r7'].object.planSha256 -eq $evidence['plan-v7'].sha256 -and
            $evidence['plan-v8'].object.parentPlanSha256 -eq $evidence['plan-v7'].sha256 -and
            $evidence['plan-v8'].object.parentManifestSha256 -eq $evidence['manifest-r7'].sha256 -and
            $evidence['manifest-r8'].object.planSha256 -eq $evidence['plan-v8'].sha256 -and
            $evidence['plan-v9'].object.parentPlanSha256 -eq $evidence['plan-v8'].sha256 -and
            $evidence['plan-v9'].object.parentManifestSha256 -eq $evidence['manifest-r8'].sha256 -and
            $evidence['manifest-r9'].object.planSha256 -eq $evidence['plan-v9'].sha256
        )
    }

    $run9ScriptLinkPass = $false
    if ($evidence.ContainsKey('plan-v9') -and $evidence.ContainsKey('manifest-r9')) {
        $run9ScriptLinkPass = (
            $run9ScriptSha256 -eq $ExpectedRun9ScriptSha256 -and
            $evidence['plan-v9'].object.scriptSha256 -eq $run9ScriptSha256 -and
            $evidence['manifest-r9'].object.scriptSha256 -eq $run9ScriptSha256
        )
    }

    $hostIsWindowsPowerShell51 = (
        $PSVersionTable.PSVersion.Major -eq 5 -and
        $PSVersionTable.PSVersion.Minor -eq 1 -and
        $PSVersionTable.PSEdition -eq 'Desktop'
    )
    $powerShellPath = [IO.Path]::GetFullPath(
        (Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe')
    )
    $childPowerShellPathPass = (
        [IO.File]::Exists($powerShellPath) -and
        [IO.Path]::GetFileName($powerShellPath) -ieq 'powershell.exe'
    )
    $prelaunchPass = (
        $hostIsWindowsPowerShell51 -and
        $childPowerShellPathPass -and
        $run9ScriptSha256 -eq $ExpectedRun9ScriptSha256 -and
        $classifierSha256 -eq $ExpectedErrorClassifierSha256 -and
        $run9Ast.pass -and
        $classifierAst.pass -and
        $invalidCanonicalJson -eq 0 -and
        $duplicateEvidence -eq 0 -and
        $evidenceHashPass -and
        $parentChainPass -and
        $run9ScriptLinkPass -and
        $runbookToolHashPass
    )

    if (-not $prelaunchPass) {
        $prelaunchFailure = [ordered]@{
            mode = 'gate2_offline_verify'
            verifierId = $VerifierId
            phase = 'prelaunch'
            hostIsWindowsPowerShell51 = $hostIsWindowsPowerShell51
            childPowerShellPathPass = $childPowerShellPathPass
            run9HashMatch = ($run9ScriptSha256 -eq $ExpectedRun9ScriptSha256)
            classifierHashMatch = ($classifierSha256 -eq $ExpectedErrorClassifierSha256)
            run9AstPass = $run9Ast.pass
            classifierAstPass = $classifierAst.pass
            evidenceHashPass = $evidenceHashPass
            parentChainPass = $parentChainPass
            run9ScriptLinkPass = $run9ScriptLinkPass
            runbookToolHashPass = $runbookToolHashPass
            runbookClassifierHashLabelCount = $documentedClassifierHashes.Count
            runbookVerifierHashLabelCount = $documentedVerifierHashes.Count
            childProcessesStarted = 0
            networkCalls = 0
            providerBehaviorVerified = $false
            pass = $false
        }
        $prelaunchFailure | ConvertTo-Json -Depth 4 -Compress
        exit 1
    }

    $childVersionProbe = Invoke-ChildVersionProbe -PowerShellPath $powerShellPath
    $childPowerShellVersionPass = (
        $childVersionProbe.exitCode -eq 0 -and
        $childVersionProbe.stderrLength -eq 0 -and
        $childVersionProbe.stdout -ceq '5.1|Desktop'
    )
    if (-not $childPowerShellVersionPass) {
        $childVersionFailure = [ordered]@{
            mode = 'gate2_offline_verify'
            verifierId = $VerifierId
            phase = 'child_host_version'
            hostIsWindowsPowerShell51 = $hostIsWindowsPowerShell51
            childPowerShellPathPass = $childPowerShellPathPass
            childPowerShellVersionPass = $false
            childProcessesStarted = 1
            networkCalls = 0
            providerBehaviorVerified = $false
            pass = $false
        }
        $childVersionFailure | ConvertTo-Json -Depth 4 -Compress
        exit 1
    }

    $legacyOne = Invoke-OfflineChild -PowerShellPath $powerShellPath -ScriptPath $run9ScriptPath -ModeArgument '-OfflineSelfTest'
    $legacyTwo = Invoke-OfflineChild -PowerShellPath $powerShellPath -ScriptPath $run9ScriptPath -ModeArgument '-OfflineSelfTest'
    $legacyObject = $legacyOne.stdout | ConvertFrom-Json
    $legacySelfTestPass = (
        $legacyOne.exitCode -eq 0 -and
        $legacyTwo.exitCode -eq 0 -and
        $legacyOne.stderrLength -eq 0 -and
        $legacyTwo.stderrLength -eq 0 -and
        $legacyOne.stdout -ceq $legacyTwo.stdout -and
        $legacyObject.mode -eq 'offline_self_test' -and
        $legacyObject.scriptSha256 -eq $run9ScriptSha256 -and
        $legacyObject.fixtureCount -eq 25 -and
        $legacyObject.allExpected -and
        $legacyObject.unhandledCount -eq 0 -and
        $legacyObject.networkCalls -eq 0 -and
        $legacyObject.pass
    )

    $classifierOne = Invoke-OfflineChild -PowerShellPath $powerShellPath -ScriptPath $classifierPath
    $classifierTwo = Invoke-OfflineChild -PowerShellPath $powerShellPath -ScriptPath $classifierPath
    $classifierObject = $classifierOne.stdout | ConvertFrom-Json
    $childOutputRedactionPass = (
        -not $legacyOne.stdout.Contains('SYNTH_ONLY_DO_NOT_EMIT_7F4A9C') -and
        -not $legacyTwo.stdout.Contains('SYNTH_ONLY_DO_NOT_EMIT_7F4A9C') -and
        -not $classifierOne.stdout.Contains('SYNTH_ONLY_DO_NOT_EMIT_7F4A9C') -and
        -not $classifierTwo.stdout.Contains('SYNTH_ONLY_DO_NOT_EMIT_7F4A9C') -and
        -not $legacyOne.stdout.Contains('https://synthetic.invalid/path?') -and
        -not $legacyTwo.stdout.Contains('https://synthetic.invalid/path?') -and
        -not $classifierOne.stdout.Contains('https://synthetic.invalid/path?') -and
        -not $classifierTwo.stdout.Contains('https://synthetic.invalid/path?') -and
        -not $legacyOne.stdout.Contains('serviceKey=') -and
        -not $legacyTwo.stdout.Contains('serviceKey=') -and
        -not $classifierOne.stdout.Contains('serviceKey=') -and
        -not $classifierTwo.stdout.Contains('serviceKey=')
    )
    $classifierSelfTestPass = (
        $classifierOne.exitCode -eq 0 -and
        $classifierTwo.exitCode -eq 0 -and
        $classifierOne.stderrLength -eq 0 -and
        $classifierTwo.stderrLength -eq 0 -and
        $classifierOne.stdout -ceq $classifierTwo.stdout -and
        $classifierObject.scriptSha256 -eq $classifierSha256 -and
        $classifierObject.fixtureCount -eq 16 -and
        $classifierObject.fixtureSetPass -and
        $classifierObject.fixtureHashLockPass -and
        $classifierObject.allExpected -and
        $classifierObject.deterministic -and
        $classifierObject.unhandledCount -eq 0 -and
        $classifierObject.redactionPass -and
        $classifierObject.networkCalls -eq 0 -and
        $classifierObject.retryExecuted -eq 0 -and
        -not $classifierObject.sameRunRetryAllowed -and
        -not $classifierObject.retryPolicyExecutionVerified -and
        -not $classifierObject.providerBehaviorVerified -and
        $classifierObject.pass
    )

    $pass = (
        $prelaunchPass -and
        $childOutputRedactionPass -and
        $legacySelfTestPass -and
        $classifierSelfTestPass
    )

    $result = [ordered]@{
        mode = 'gate2_offline_verify'
        verifierId = $VerifierId
        verifierScriptSha256 = $verifierScriptSha256
        run9ScriptSha256 = $run9ScriptSha256
        errorClassifierSha256 = $classifierSha256
        hostIsWindowsPowerShell51 = $hostIsWindowsPowerShell51
        childPowerShellPathPass = $childPowerShellPathPass
        childPowerShellVersionPass = $childPowerShellVersionPass
        prelaunchPass = $prelaunchPass
        run9AstPass = $run9Ast.pass
        run9GetResponseSites = $run9Ast.getResponseSites
        run9GetResponseInsideLoop = $run9Ast.getResponseInsideLoop
        classifierAstPass = $classifierAst.pass
        classifierNetworkMemberSites = $classifierAst.networkMemberSites
        canonicalEvidenceCount = $evidence.Count
        canonicalJsonInvalid = $invalidCanonicalJson
        canonicalEvidenceDuplicates = $duplicateEvidence
        evidenceHashPass = $evidenceHashPass
        parentChainPass = $parentChainPass
        run9ScriptLinkPass = $run9ScriptLinkPass
        runbookToolHashPass = $runbookToolHashPass
        runbookClassifierHashLabelCount = $documentedClassifierHashes.Count
        runbookVerifierHashLabelCount = $documentedVerifierHashes.Count
        legacyFixtureCount = $legacyObject.fixtureCount
        legacyFixtureDescriptorSha256 = $legacyObject.fixtureDescriptorSha256
        legacyResultProjectionSha256 = $legacyObject.resultProjectionSha256
        legacyFreshProcessDeterministic = ($legacyOne.stdout -ceq $legacyTwo.stdout)
        legacyStdoutSha256 = Get-TextSha256 -Text $legacyOne.stdout
        legacySelfTestPass = $legacySelfTestPass
        errorFixtureCount = $classifierObject.fixtureCount
        errorFixtureDescriptorSha256 = $classifierObject.descriptorSha256
        errorResultProjectionSha256 = $classifierObject.resultProjectionSha256
        errorFreshProcessDeterministic = ($classifierOne.stdout -ceq $classifierTwo.stdout)
        errorStdoutSha256 = Get-TextSha256 -Text $classifierOne.stdout
        errorClassifierSelfTestPass = $classifierSelfTestPass
        childOutputRedactionPass = $childOutputRedactionPass
        childProcessesStarted = 5
        networkCalls = 0
        providerBehaviorVerified = $false
        pass = $pass
    }

    $result | ConvertTo-Json -Depth 5 -Compress
    if (-not $pass) {
        exit 1
    }
}
catch {
    $failure = [ordered]@{
        mode = 'gate2_offline_verify'
        verifierId = $VerifierId
        errorClass = $_.Exception.GetType().FullName
        networkCalls = 0
        providerBehaviorVerified = $false
        pass = $false
    }
    $failure | ConvertTo-Json -Depth 4 -Compress
    exit 1
}
