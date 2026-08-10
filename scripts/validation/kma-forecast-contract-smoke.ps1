param(
    [switch]$OfflineSelfTest,
    [switch]$PlanPreflight,
    [switch]$Execute,
    [string]$ExpectedPlanHash
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'
$DebugPreference = 'SilentlyContinue'
$InformationPreference = 'SilentlyContinue'
$script:ObservedNetworkCalls = 0

# Contract constants. Changing this block requires a new script hash and plan.
$Contract = [ordered]@{
    SchemaVersion = 'kma-forecast-contract-smoke-plan-v1'
    ValidatorId = 'kma-forecast-validator-v1-offline'
    PlanRelativePath = 'docs\validation-plans\kma-forecast-contract-smoke-plan.json'
    ScriptRelativePath = 'scripts/validation/kma-forecast-contract-smoke.ps1'
    Scheme = 'https'
    Host = 'apis.data.go.kr'
    KeyParameter = 'serviceKey'
    ResponseLimitBytes = 2097152
    TimeoutMilliseconds = 15000
    InterCallDelayMilliseconds = 2000
    NetworkCallUpperBound = 2
    HardCap = 30
    TargetNx = 60
    TargetNy = 127
    SecretRelativePath = 'NowSignal\Secrets\data-go-kr.clixml'
    SyntheticMarker = 'SYNTH_ONLY_DO_NOT_EMIT_KMA_4C17B9'
    PlanId = 'contract-smoke-20260810-v10'
    RunId = 'contract-smoke-20260810-r10'
    ParentPlanId = 'contract-smoke-20260810-v9'
    ParentRunId = 'contract-smoke-20260810-r9'
    ParentPlanSha256 = 'd3eb18ad5cd364d1515acd74fd94fe43ba87f3ff012172264290d588d905715b'
    ParentManifestSha256 = '732775583ff2b3917b3d8ce5f7076238475ebc0a2aa46354e458c6ec9985bdf2'
    ParentOutcome = 'run9_c01_fail_conflicting_official_schema_preserved'
    ResumptionReason = 'independent_kma_forecast_scope_not_blocked_by_airkorea_inquiry'
    OwnerApproval = 'explicit_user_next_gate2_validation_request_2026-08-10_max2'
    FixedAt = '2026-08-10T13:20:26+09:00'
    BudgetDate = '2026-08-10'
    PreCallCount = 10
    ExpectedPostCallCount = 12
    C11EvaluationMode = 'capture_only_not_evaluated'
    ProviderId = 'kma-data-go-kr-vilage-fcst'
    LicenseRegisterId = 'LIC-KMA-001'
    TermsUrl = 'https://www.kogl.or.kr/info/licenseType1.do'
    TermsEvidenceProjectionSha256 = '96dac73507bd3de1d5af08726d7a3552581cff25e7d4da86c69da056ecd7af00'
    AttributionTemplateId = 'ATTR-KMA-FCST-001'
    AttributionTemplateUtf8Base64 = '7Lac7LKYOiDquLDsg4Hssq0g64uo6riw7JiI67O0IOyhsO2ajOyEnOu5hOyKpCDCtyDrsJztkZwg65iQ64qUIOq0gOy4oSB7c291cmNlVGltZX0gS1NUIMK3IO2ZleyduCB7ZmV0Y2hlZEF0fSDCtyDsm5DrrLgge3NvdXJjZVJlZmVyZW5jZX0='
}

# Endpoint and schema constants. Runtime plans may set only date and base time.
$EndpointSchemas = @(
    [pscustomobject][ordered]@{
        id = 'getUltraSrtFcst'
        endpointPath = '/getUltraSrtFcst'
        servicePath = '/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst'
        schemaId = 'kma-ultra-srt-fcst-item-v1'
        requiredFields = @('baseDate','baseTime','category','fcstDate','fcstTime','fcstValue','nx','ny')
        requiredCategories = @('PTY','RN1','T1H','REH','WSD')
        sourceUrl = 'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst'
        units = @(@('PTY','code'),@('RN1','category_1mm'),@('T1H','degC'),@('REH','percent'),@('WSD','m/s'))
        expectedBaseDate = '20260810'
        expectedBaseTime = '1130'
        baseTimePattern = '^(?:[01][0-9]|2[0-3])30$'
    },
    [pscustomobject][ordered]@{
        id = 'getVilageFcst'
        endpointPath = '/getVilageFcst'
        servicePath = '/1360000/VilageFcstInfoService_2.0/getVilageFcst'
        schemaId = 'kma-vilage-fcst-item-v1'
        requiredFields = @('baseDate','baseTime','category','fcstDate','fcstTime','fcstValue','nx','ny')
        requiredCategories = @('PTY','PCP','POP','TMP','REH','WSD')
        sourceUrl = 'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst'
        units = @(@('PTY','code'),@('PCP','category_1mm'),@('POP','percent'),@('TMP','degC'),@('REH','percent'),@('WSD','m/s'))
        expectedBaseDate = '20260810'
        expectedBaseTime = '1100'
        baseTimePattern = '^(0200|0500|0800|1100|1400|1700|2000|2300)$'
    }
)

$ExpectedPlanProperties = @(
    'schemaVersion','planId','runId','parentPlanId','parentRunId','parentPlanSha256',
    'parentManifestSha256','parentOutcome','resumptionReason',
    'fixedAt','budgetDate','budgetTimezone','ownerApproval','scriptPath','scriptSha256',
    'scriptEncoding','scriptHashMode','scheme','host','method','requestBody','transport',
    'executionMode','sentinelCalls','networkCallUpperBound','networkCallSiteUpperBound',
    'retry','parallel','redirect','timeoutSeconds','readWriteTimeoutSeconds',
    'responseLimitBytes','automaticDecompression','keepAlive','requestIntervalMilliseconds',
    'preCallCount','expectedPostCallCount','hardCap','keyParameter','keySource',
    'sameUserSidRequired','secretPathOutsideRepoAndOneDriveRequired','secretNoReparseRequired',
    'secretMetadataGateBeforeImport','keyEncoding','serviceKeyCountRequired',
    'keyRoundTripRequired','prePostC12','c12Scope','c12Representations',
    'c12ScanErrorsMustBeZero','abortOnC12NonZero','runtimeOutputSecretScanRequired',
    'errorBufferClearRequired','zeroFreeBstrRequired','cleanupFailureMustBeFalse',
    'consoleOutput','rawResponseStorage','fullUrlStorage','exceptionTextStorage',
    'processIsolation','stopOnTransportOrSecurityFailure','c11EvaluationMode','endpoints',
    'validatorFixtureCount','validatorFixtureDescriptorSha256','validatorResultProjectionSha256'
)

$ExpectedEndpointPlanProperties = @(
    'id','endpointPath','schemaId','parameters','queryParameterOrder',
    'requiredFields','requiredCategories','sourceUrl','sourceId','licenseRegisterId',
    'termsUrl','termsEvidenceProjection','termsEvidenceProjectionSha256',
    'timePolicy','locationPolicy','unitApplicability','units','attributionTemplateId',
    'attributionRequiredTokens','layerPolicy'
)

function Get-BytesSha256 {
    param([Parameter(Mandatory = $true)][byte[]]$Bytes)

    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha.ComputeHash($Bytes)
        return ([BitConverter]::ToString($hash)).Replace('-', '').ToLowerInvariant()
    }
    finally {
        if ($null -ne $sha) { $sha.Dispose() }
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

function Get-PropertyRecord {
    param($Object, [Parameter(Mandatory = $true)][string]$Name)

    if ($null -eq $Object) {
        return [pscustomobject]@{ exists = $false; value = $null }
    }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return [pscustomobject]@{ exists = $false; value = $null }
    }
    return [pscustomobject]@{ exists = $true; value = $property.Value }
}

function Test-AvailableValue {
    param($Value)

    if ($null -eq $Value) { return $false }
    if ($Value -is [string]) {
        return (-not [string]::IsNullOrWhiteSpace($Value) -and $Value -ne '-')
    }
    return $true
}

function Test-ExactPropertySet {
    param(
        $Object,
        [Parameter(Mandatory = $true)][string[]]$Expected
    )

    if ($null -eq $Object) { return $false }
    $actual = @($Object.PSObject.Properties.Name)
    if ($actual.Count -ne $Expected.Count) { return $false }
    foreach ($name in $Expected) {
        if (-not ($actual -ccontains $name)) { return $false }
    }
    foreach ($name in $actual) {
        if (-not ($Expected -ccontains $name)) { return $false }
    }
    return $true
}

function Get-OccurrenceCount {
    param(
        [AllowNull()][string]$Text,
        [AllowNull()][string]$Needle
    )

    if ([string]::IsNullOrEmpty($Text) -or [string]::IsNullOrEmpty($Needle)) { return 0 }
    $count = 0
    $offset = 0
    while ($offset -le ($Text.Length - $Needle.Length)) {
        $found = $Text.IndexOf($Needle, $offset, [StringComparison]::Ordinal)
        if ($found -lt 0) { break }
        $count++
        $offset = $found + $Needle.Length
    }
    return $count
}

function Get-ByteOccurrenceCount {
    param(
        [AllowNull()][byte[]]$Bytes,
        [AllowNull()][byte[]]$Needle
    )

    if ($null -eq $Bytes -or $null -eq $Needle -or $Needle.Length -eq 0 -or $Bytes.Length -lt $Needle.Length) {
        return 0
    }
    $count = 0
    for ($offset = 0; $offset -le ($Bytes.Length - $Needle.Length); $offset++) {
        $matched = $true
        for ($index = 0; $index -lt $Needle.Length; $index++) {
            if ($Bytes[$offset + $index] -ne $Needle[$index]) {
                $matched = $false
                break
            }
        }
        if ($matched) {
            $count++
            $offset += ($Needle.Length - 1)
        }
    }
    return $count
}

function Get-C12Counts {
    param(
        [Parameter(Mandatory = $true)][string]$Raw,
        [Parameter(Mandatory = $true)][string]$Encoded,
        [Parameter(Mandatory = $true)][string]$RepoRoot
    )

    $rawRepo = 0
    $encodedRepo = 0
    $rawEnv = 0
    $encodedEnv = 0
    $scanErrors = 0
    $fileCount = 0
    $repoPrefix = [IO.Path]::GetFullPath($RepoRoot).TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    $gitPrefix = [IO.Path]::GetFullPath((Join-Path $RepoRoot '.git')).TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    $encodedLowerEscapes = [regex]::Replace(
        $Encoded,
        '%[0-9A-F]{2}',
        { param($match) $match.Value.ToLowerInvariant() }
    )
    $rawNeedles = @(
        [Text.Encoding]::UTF8.GetBytes($Raw),
        [Text.Encoding]::Unicode.GetBytes($Raw),
        [Text.Encoding]::BigEndianUnicode.GetBytes($Raw)
    )
    $encodedValues = @($Encoded)
    if ($encodedLowerEscapes -cne $Encoded) { $encodedValues += $encodedLowerEscapes }
    $encodedNeedles = @()
    foreach ($encodedValue in $encodedValues) {
        $encodedNeedles += ,([Text.Encoding]::UTF8.GetBytes($encodedValue))
        $encodedNeedles += ,([Text.Encoding]::Unicode.GetBytes($encodedValue))
        $encodedNeedles += ,([Text.Encoding]::BigEndianUnicode.GetBytes($encodedValue))
    }

    $enumerationErrors = @()
    $files = @(Get-ChildItem -LiteralPath $RepoRoot -Recurse -Force -File -ErrorAction SilentlyContinue -ErrorVariable +enumerationErrors)
    $scanErrors += @($enumerationErrors).Count
    foreach ($file in $files) {
        try {
            $full = [IO.Path]::GetFullPath($file.FullName)
            if (-not $full.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase)) {
                $scanErrors++
                continue
            }
            if ($full.StartsWith($gitPrefix, [StringComparison]::OrdinalIgnoreCase)) { continue }
            $fileCount++
            $contentBytes = [IO.File]::ReadAllBytes($full)
            foreach ($needle in $rawNeedles) {
                $rawRepo += Get-ByteOccurrenceCount -Bytes $contentBytes -Needle $needle
            }
            foreach ($needle in $encodedNeedles) {
                $encodedRepo += Get-ByteOccurrenceCount -Bytes $contentBytes -Needle $needle
            }
            $contentBytes = $null
        }
        catch {
            $scanErrors++
        }
    }

    try {
        foreach ($entry in Get-ChildItem Env:) {
            $value = [string]$entry.Value
            $rawEnv += Get-OccurrenceCount -Text $value -Needle $Raw
            foreach ($encodedValue in $encodedValues) {
                $encodedEnv += Get-OccurrenceCount -Text $value -Needle $encodedValue
            }
            $value = $null
        }
    }
    catch {
        $scanErrors++
    }

    $rawNeedles = $null
    $encodedNeedles = $null
    $encodedValues = $null
    $encodedLowerEscapes = $null
    return [pscustomobject][ordered]@{
        rawRepo = $rawRepo
        encodedRepo = $encodedRepo
        rawEnv = $rawEnv
        encodedEnv = $encodedEnv
        scanErrors = $scanErrors
        fileCount = $fileCount
    }
}

function Read-LimitedUtf8 {
    param(
        [Parameter(Mandatory = $true)][IO.Stream]$Stream,
        [Parameter(Mandatory = $true)][int]$Limit
    )

    $memory = New-Object IO.MemoryStream
    try {
        $buffer = New-Object byte[] 8192
        while ($true) {
            $read = $Stream.Read($buffer, 0, $buffer.Length)
            if ($read -le 0) { break }
            if (($memory.Length + $read) -gt $Limit) {
                throw [IO.InvalidDataException]::new('response_limit_exceeded')
            }
            $memory.Write($buffer, 0, $read)
        }
        $strictUtf8 = New-Object Text.UTF8Encoding($false, $true)
        return $strictUtf8.GetString($memory.ToArray())
    }
    finally {
        if ($null -ne $memory) { $memory.Dispose() }
    }
}

function Get-SafeTypeName {
    param($Value)

    if ($null -eq $Value) { return 'Null' }
    if ($Value -is [string]) { return 'String' }
    if ($Value -is [int16] -or $Value -is [int32] -or $Value -is [int64]) { return 'Integer' }
    if ($Value -is [decimal] -or $Value -is [double] -or $Value -is [single]) { return 'Number' }
    if ($Value -is [bool]) { return 'Boolean' }
    return 'Unsupported'
}

function Test-KmaTimestamp {
    param(
        [AllowNull()][string]$DateText,
        [AllowNull()][string]$TimeText
    )

    if ($DateText -notmatch '^[0-9]{8}$' -or $TimeText -notmatch '^[0-9]{4}$') { return $false }
    $parsed = [datetime]::MinValue
    return [datetime]::TryParseExact(
        $DateText + $TimeText,
        'yyyyMMddHHmm',
        [Globalization.CultureInfo]::InvariantCulture,
        [Globalization.DateTimeStyles]::None,
        [ref]$parsed
    )
}

function Convert-KmaTimestamp {
    param(
        [AllowNull()][string]$DateText,
        [AllowNull()][string]$TimeText
    )

    if (-not (Test-KmaTimestamp -DateText $DateText -TimeText $TimeText)) { return $null }
    $parsed = [datetime]::ParseExact(
        $DateText + $TimeText,
        'yyyyMMddHHmm',
        [Globalization.CultureInfo]::InvariantCulture
    )
    $offset = New-Object TimeSpan(9, 0, 0)
    return ([DateTimeOffset]::new($parsed, $offset)).ToString('yyyy-MM-ddTHH:mm:sszzz')
}

function ConvertTo-SafeKmaValidation {
    param(
        [Parameter(Mandatory = $true)][string]$Body,
        [Parameter(Mandatory = $true)]$Schema,
        [Parameter(Mandatory = $true)]$EndpointPlan,
        [Parameter(Mandatory = $true)][string]$FetchedAt,
        [Parameter(Mandatory = $true)][bool]$PlanC11BindingVerified
    )

    $result = [ordered]@{
        providerCode = $null
        providerHeaderStatus = 'not_observed'
        jsonHeaderParse = 'not_observed'
        dataBodyStatus = 'not_observed'
        schemaStatus = 'not_observed'
        itemCount = 0
        missingRequiredFields = @()
        missingRequiredCategories = @()
        fieldSignature = @()
        gridMatch = $false
        baseTimeParseable = $false
        forecastTimeParseable = $false
        baseEchoMatch = $false
        paginationComplete = $false
        valueDomainPass = $false
        fetchedAt = $FetchedAt
        observedAt = $null
        issuedAt = $null
        validFrom = $null
        validUntil = $null
        validUntilNullReason = 'official_interval_end_not_provided'
        regionGridX = $Contract.TargetNx
        regionGridY = $Contract.TargetNy
        unitApplicability = 'field_level'
        unitSignature = @()
        sourceUrlSha256 = $null
        sourceUrlMatch = $false
        sourceIdNull = $false
        licenseRegisterId = $null
        termsUrlSha256 = $null
        termsUrlMatch = $false
        termsEvidenceProjectionSha256 = $null
        termsEvidenceMatch = $false
        attributionTemplateId = $null
        attributionRequiredTokensPresent = $false
        attributionRenderedSha256 = $null
        immutableOriginalPresent = (-not [string]::IsNullOrEmpty($Body))
        derivedLayerPresent = $false
        layersSeparated = $false
        c11CaptureComplete = $false
        c11 = 'not_run'
        resultKind = 'unavailable'
        errorClass = 'malformed_json'
        c01 = 'fail'
    }

    try {
        $document = ConvertFrom-Json -InputObject $Body
        $responseRecord = Get-PropertyRecord -Object $document -Name 'response'
        if (-not $responseRecord.exists) { return [pscustomobject]$result }
        $headerRecord = Get-PropertyRecord -Object $responseRecord.value -Name 'header'
        if (-not $headerRecord.exists) { return [pscustomobject]$result }
        $codeRecord = Get-PropertyRecord -Object $headerRecord.value -Name 'resultCode'
        if ($codeRecord.exists -and [string]$codeRecord.value -match '^[0-9]{2}$') {
            $result.providerCode = [string]$codeRecord.value
            $result.jsonHeaderParse = 'pass'
        }
        else {
            $result.errorClass = 'provider_header_invalid'
            return [pscustomobject]$result
        }
        if ($result.providerCode -ne '00') {
            $result.providerHeaderStatus = 'observed_error'
            $result.errorClass = 'provider_error'
            return [pscustomobject]$result
        }
        $result.providerHeaderStatus = 'observed_success'

        $bodyRecord = Get-PropertyRecord -Object $responseRecord.value -Name 'body'
        if (-not $bodyRecord.exists) {
            $result.errorClass = 'data_body_missing'
            return [pscustomobject]$result
        }
        $itemsRecord = Get-PropertyRecord -Object $bodyRecord.value -Name 'items'
        $itemRecord = if ($itemsRecord.exists) {
            Get-PropertyRecord -Object $itemsRecord.value -Name 'item'
        }
        else {
            [pscustomobject]@{ exists = $false; value = $null }
        }
        if (-not $itemRecord.exists -or $null -eq $itemRecord.value) {
            $result.dataBodyStatus = 'empty'
            $result.schemaStatus = 'items_missing'
            $result.errorClass = 'items_missing'
            return [pscustomobject]$result
        }

        $items = @($itemRecord.value)
        if ($items.Count -eq 0) {
            $result.dataBodyStatus = 'empty'
            $result.schemaStatus = 'items_missing'
            $result.errorClass = 'items_missing'
            return [pscustomobject]$result
        }
        $result.dataBodyStatus = 'observed'
        $result.itemCount = $items.Count

        $pageRecord = Get-PropertyRecord -Object $bodyRecord.value -Name 'pageNo'
        $rowsRecord = Get-PropertyRecord -Object $bodyRecord.value -Name 'numOfRows'
        $totalRecord = Get-PropertyRecord -Object $bodyRecord.value -Name 'totalCount'
        $pageValue = 0
        $rowsValue = 0
        $totalValue = -1
        $pageParsed = [int]::TryParse([string]$pageRecord.value, [ref]$pageValue)
        $rowsParsed = [int]::TryParse([string]$rowsRecord.value, [ref]$rowsValue)
        $totalParsed = [int]::TryParse([string]$totalRecord.value, [ref]$totalValue)
        $expectedPage = Get-ParameterValue -EndpointPlan $EndpointPlan -Name 'pageNo'
        $expectedRows = Get-ParameterValue -EndpointPlan $EndpointPlan -Name 'numOfRows'
        $result.paginationComplete = (
            $pageRecord.exists -and $rowsRecord.exists -and $totalRecord.exists -and
            $pageParsed -and $rowsParsed -and $totalParsed -and
            [string]$pageValue -ceq [string]$expectedPage -and
            [string]$rowsValue -ceq [string]$expectedRows -and
            $totalValue -eq $items.Count -and $totalValue -le $rowsValue
        )

        $missing = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
        $nulls = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
        $seenCategories = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
        $signature = [ordered]@{}
        $allGridMatch = $true
        $allBaseTimesParseable = $true
        $allForecastTimesParseable = $true
        $allBaseEchoMatch = $true
        $allValuesValid = $true
        $forecastKeys = New-Object 'System.Collections.Generic.List[string]'
        $expectedBaseDate = Get-ParameterValue -EndpointPlan $EndpointPlan -Name 'base_date'
        $expectedBaseTime = Get-ParameterValue -EndpointPlan $EndpointPlan -Name 'base_time'

        foreach ($item in $items) {
            $categoryRecord = Get-PropertyRecord -Object $item -Name 'category'
            $category = if ($categoryRecord.exists) { [string]$categoryRecord.value } else { $null }
            $isRequiredCategory = (@($Schema.requiredCategories) -ccontains $category)
            $valueRecord = Get-PropertyRecord -Object $item -Name 'fcstValue'
            $isPrecipitation = ($category -ceq 'RN1' -or $category -ceq 'PCP')
            $valueText = if ($valueRecord.exists -and $null -ne $valueRecord.value) { [string]$valueRecord.value } else { $null }
            $numericValue = [decimal]0
            $numericParsed = if ($null -ne $valueText -and -not [string]::IsNullOrWhiteSpace($valueText)) {
                [decimal]::TryParse(
                    $valueText,
                    [Globalization.NumberStyles]::Float,
                    [Globalization.CultureInfo]::InvariantCulture,
                    [ref]$numericValue
                )
            }
            else { $false }
            $allowedNoPrecip = (
                $isPrecipitation -and (
                    $null -eq $valueRecord.value -or $valueText -ceq '-' -or ($numericParsed -and $numericValue -eq 0)
                )
            )
            $sentinelValue = ($null -ne $valueText -and $valueText -match '^[+-]900(?:\.0+)?$')
            $precipitationValueValid = (
                $isPrecipitation -and (
                    $allowedNoPrecip -or
                    (-not [string]::IsNullOrWhiteSpace($valueText) -and -not $sentinelValue)
                )
            )
            if ($isRequiredCategory -and (
                -not $valueRecord.exists -or $sentinelValue -or
                ($isPrecipitation -and -not $precipitationValueValid) -or
                (-not $isPrecipitation -and (-not $numericParsed -or [string]::IsNullOrWhiteSpace($valueText)))
            )) {
                $allValuesValid = $false
            }

            foreach ($field in @($Schema.requiredFields)) {
                $fieldRecord = Get-PropertyRecord -Object $item -Name $field
                if (-not $fieldRecord.exists) {
                    [void]$missing.Add($field)
                    continue
                }
                if (-not (Test-AvailableValue -Value $fieldRecord.value) -and
                    -not ($field -ceq 'fcstValue' -and (-not $isRequiredCategory -or $allowedNoPrecip))) {
                    [void]$nulls.Add($field)
                }
                if (-not $signature.Contains($field)) {
                    $signature[$field] = Get-SafeTypeName -Value $fieldRecord.value
                }
            }

            if ($categoryRecord.exists -and (Test-AvailableValue -Value $categoryRecord.value)) {
                if (@($Schema.requiredCategories) -ccontains $category) {
                    [void]$seenCategories.Add($category)
                }
            }

            $nxRecord = Get-PropertyRecord -Object $item -Name 'nx'
            $nyRecord = Get-PropertyRecord -Object $item -Name 'ny'
            if (-not $nxRecord.exists -or -not $nyRecord.exists -or
                [string]$nxRecord.value -cne [string]$Contract.TargetNx -or
                [string]$nyRecord.value -cne [string]$Contract.TargetNy) {
                $allGridMatch = $false
            }

            $baseDate = Get-PropertyRecord -Object $item -Name 'baseDate'
            $baseTime = Get-PropertyRecord -Object $item -Name 'baseTime'
            if (-not (Test-KmaTimestamp -DateText ([string]$baseDate.value) -TimeText ([string]$baseTime.value))) {
                $allBaseTimesParseable = $false
            }
            if ([string]$baseDate.value -cne [string]$expectedBaseDate -or
                [string]$baseTime.value -cne [string]$expectedBaseTime) {
                $allBaseEchoMatch = $false
            }
            $fcstDate = Get-PropertyRecord -Object $item -Name 'fcstDate'
            $fcstTime = Get-PropertyRecord -Object $item -Name 'fcstTime'
            if (-not (Test-KmaTimestamp -DateText ([string]$fcstDate.value) -TimeText ([string]$fcstTime.value))) {
                $allForecastTimesParseable = $false
            }
            else {
                [void]$forecastKeys.Add(([string]$fcstDate.value + [string]$fcstTime.value))
            }
        }

        foreach ($field in @($Schema.requiredFields)) {
            if (-not $signature.Contains($field)) { $signature[$field] = 'Missing' }
            if ($signature[$field] -eq 'Unsupported') { [void]$missing.Add($field) }
        }
        $missingCategories = @()
        foreach ($category in @($Schema.requiredCategories)) {
            if (-not $seenCategories.Contains($category)) { $missingCategories += $category }
        }

        $result.missingRequiredFields = @($missing | Sort-Object) + @($nulls | Sort-Object)
        $result.missingRequiredFields = @($result.missingRequiredFields | Select-Object -Unique)
        $result.missingRequiredCategories = @($missingCategories | Sort-Object)
        $result.fieldSignature = @(
            @($Schema.requiredFields) | ForEach-Object { '{0}:{1}' -f $_, [string]$signature[$_] }
        )
        $result.gridMatch = $allGridMatch
        $result.baseTimeParseable = $allBaseTimesParseable
        $result.forecastTimeParseable = $allForecastTimesParseable
        $result.baseEchoMatch = $allBaseEchoMatch
        $result.valueDomainPass = $allValuesValid
        $result.issuedAt = Convert-KmaTimestamp -DateText $expectedBaseDate -TimeText $expectedBaseTime
        if ($forecastKeys.Count -gt 0) {
            $firstForecast = @($forecastKeys | Sort-Object)[0]
            $result.validFrom = Convert-KmaTimestamp -DateText $firstForecast.Substring(0, 8) -TimeText $firstForecast.Substring(8, 4)
        }

        $result.unitSignature = @($Schema.units | ForEach-Object { '{0}:{1}' -f [string]$_[0], [string]$_[1] })
        $result.sourceUrlSha256 = Get-TextSha256 -Text ([string]$EndpointPlan.sourceUrl)
        $result.sourceUrlMatch = (
            [string]$EndpointPlan.sourceUrl -ceq [string]$Schema.sourceUrl -and
            [string]$EndpointPlan.sourceUrl -notmatch '[?&]' -and
            [string]$EndpointPlan.sourceUrl -match '^https://'
        )
        $result.sourceIdNull = ($null -eq $EndpointPlan.sourceId)
        $result.licenseRegisterId = [string]$EndpointPlan.licenseRegisterId
        $result.termsUrlSha256 = Get-TextSha256 -Text ([string]$EndpointPlan.termsUrl)
        $result.termsUrlMatch = ([string]$EndpointPlan.termsUrl -ceq $Contract.TermsUrl)
        $result.termsEvidenceProjectionSha256 = [string]$EndpointPlan.termsEvidenceProjectionSha256
        $result.termsEvidenceMatch = (
            $PlanC11BindingVerified -and
            [string]$EndpointPlan.termsEvidenceProjectionSha256 -ceq $Contract.TermsEvidenceProjectionSha256
        )
        $result.attributionTemplateId = [string]$EndpointPlan.attributionTemplateId
        $attributionTemplate = [Text.Encoding]::UTF8.GetString(
            [Convert]::FromBase64String($Contract.AttributionTemplateUtf8Base64)
        )
        $renderedAttribution = $attributionTemplate.Replace('{sourceReference}', [string]$EndpointPlan.sourceUrl).
            Replace('{sourceTime}', [string]$result.issuedAt).
            Replace('{fetchedAt}', [string]$FetchedAt)
        $result.attributionRequiredTokensPresent = (
            $result.attributionTemplateId -ceq $Contract.AttributionTemplateId -and
            -not $renderedAttribution.Contains('{') -and
            (Get-OccurrenceCount -Text $renderedAttribution -Needle ([string]$EndpointPlan.sourceUrl)) -eq 1 -and
            (Get-OccurrenceCount -Text $renderedAttribution -Needle ([string]$result.issuedAt)) -eq 1 -and
            (Get-OccurrenceCount -Text $renderedAttribution -Needle ([string]$FetchedAt)) -eq 1
        )
        $result.attributionRenderedSha256 = Get-TextSha256 -Text $renderedAttribution
        $result.derivedLayerPresent = ($result.fieldSignature.Count -gt 0)
        $result.layersSeparated = ($result.immutableOriginalPresent -and $result.derivedLayerPresent)
        $renderedAttribution = $null
        $attributionTemplate = $null

        if ($result.missingRequiredFields.Count -gt 0) {
            $result.schemaStatus = 'required_fields_missing'
            $result.resultKind = 'partial'
            $result.errorClass = 'required_schema_missing'
        }
        elseif ($result.missingRequiredCategories.Count -gt 0) {
            $result.schemaStatus = 'required_categories_missing'
            $result.resultKind = 'partial'
            $result.errorClass = 'required_category_missing'
        }
        elseif (-not $result.gridMatch) {
            $result.schemaStatus = 'grid_mismatch'
            $result.resultKind = 'partial'
            $result.errorClass = 'grid_mismatch'
        }
        elseif (-not $result.baseTimeParseable -or -not $result.forecastTimeParseable) {
            $result.schemaStatus = 'time_invalid'
            $result.resultKind = 'partial'
            $result.errorClass = 'source_time_invalid'
        }
        elseif (-not $result.baseEchoMatch) {
            $result.schemaStatus = 'base_echo_mismatch'
            $result.resultKind = 'partial'
            $result.errorClass = 'base_echo_mismatch'
        }
        elseif (-not $result.paginationComplete) {
            $result.schemaStatus = 'pagination_incomplete'
            $result.resultKind = 'partial'
            $result.errorClass = 'pagination_incomplete'
        }
        elseif (-not $result.valueDomainPass) {
            $result.schemaStatus = 'value_domain_invalid'
            $result.resultKind = 'partial'
            $result.errorClass = 'missing_or_sentinel_value'
        }
        else {
            $result.schemaStatus = 'required_schema_observed'
            $result.resultKind = 'data'
            $result.errorClass = 'none'
            $result.c01 = 'pass'
        }
        $c11CorePass = (
            $result.c01 -ceq 'pass' -and $result.sourceUrlMatch -and $result.sourceIdNull -and
            $result.licenseRegisterId -ceq $Contract.LicenseRegisterId -and
            $result.termsUrlMatch -and $result.termsEvidenceMatch -and
            $null -eq $result.observedAt -and $null -ne $result.issuedAt -and
            $null -ne $result.validFrom -and $null -eq $result.validUntil -and
            $result.validUntilNullReason -ceq 'official_interval_end_not_provided' -and
            $result.gridMatch -and $result.unitApplicability -ceq 'field_level' -and
            $result.unitSignature.Count -eq $Schema.units.Count -and
            $result.attributionRequiredTokensPresent -and
            [string]$result.attributionRenderedSha256 -match '^[0-9a-f]{64}$' -and
            $result.immutableOriginalPresent -and $result.derivedLayerPresent -and $result.layersSeparated
        )
        $result.c11CaptureComplete = $c11CorePass
        # Full C-11 remains not evaluated in this bounded C-01 network run.
        $result.c11 = 'not_evaluated'
        return [pscustomobject]$result
    }
    catch {
        return [pscustomobject]$result
    }
}

function New-SyntheticEndpointPlan {
    param([Parameter(Mandatory = $true)]$Schema)

    $baseTime = if ($Schema.id -ceq 'getUltraSrtFcst') { '1130' } else { '1100' }
    return [pscustomobject][ordered]@{
        parameters = @(
            @('pageNo','1'),@('numOfRows','1000'),@('dataType','JSON'),
            @('base_date','20260810'),@('base_time',$baseTime),@('nx','60'),@('ny','127')
        )
        sourceUrl = $Schema.sourceUrl
        sourceId = $null
        licenseRegisterId = $Contract.LicenseRegisterId
        termsUrl = $Contract.TermsUrl
        termsEvidenceProjectionSha256 = $Contract.TermsEvidenceProjectionSha256
        attributionTemplateId = $Contract.AttributionTemplateId
    }
}

function New-SyntheticKmaBody {
    param(
        [Parameter(Mandatory = $true)]$Schema,
        [string]$ProviderCode = '00',
        [switch]$MissingField,
        [switch]$MissingCategory,
        [switch]$BaseMismatch,
        [switch]$PaginationIncomplete,
        [switch]$OptionalStringCategory,
        [ValidateSet('valid','precip_null','sentinel','empty')][string]$ValueMode = 'valid'
    )

    $items = @()
    $categories = @($Schema.requiredCategories)
    if ($MissingCategory -and $categories.Count -gt 0) {
        $categories = @($categories[0..($categories.Count - 2)])
    }
    foreach ($category in $categories) {
        $baseTime = if ($Schema.id -eq 'getUltraSrtFcst') { '1130' } else { '1100' }
        if ($BaseMismatch) { $baseTime = if ($Schema.id -eq 'getUltraSrtFcst') { '1030' } else { '0800' } }
        $item = [pscustomobject][ordered]@{
            baseDate = '20260810'
            baseTime = $baseTime
            category = $category
            fcstDate = '20260810'
            fcstTime = '0300'
            fcstValue = '1'
            nx = $Contract.TargetNx
            ny = $Contract.TargetNy
        }
        if ($MissingField -and $items.Count -eq 0) {
            [void]$item.PSObject.Properties.Remove('fcstValue')
        }
        if ($ValueMode -ceq 'precip_null' -and ($category -ceq 'RN1' -or $category -ceq 'PCP')) {
            $item.fcstValue = $null
        }
        elseif ($ValueMode -ceq 'sentinel' -and $items.Count -eq 0) {
            $item.fcstValue = '+900'
        }
        elseif ($ValueMode -ceq 'empty' -and $items.Count -eq 0) {
            $item.fcstValue = ''
        }
        $items += $item
    }
    if ($OptionalStringCategory) {
        $items += [pscustomobject][ordered]@{
            baseDate = '20260810'
            baseTime = '1100'
            category = 'SNO'
            fcstDate = '20260810'
            fcstTime = '0300'
            fcstValue = 'no_snow'
            nx = $Contract.TargetNx
            ny = $Contract.TargetNy
        }
    }
    $document = [ordered]@{
        response = [ordered]@{
            header = [ordered]@{ resultCode = $ProviderCode; resultMsg = $Contract.SyntheticMarker }
            body = [ordered]@{
                dataType = 'JSON'
                items = [ordered]@{ item = $items }
                pageNo = 1
                numOfRows = 1000
                totalCount = if ($PaginationIncomplete) { $items.Count + 1 } else { $items.Count }
            }
        }
    }
    return $document | ConvertTo-Json -Depth 10 -Compress
}

function Invoke-OfflineValidatorMatrix {
    $fixtures = @(
        [pscustomobject][ordered]@{ id = 'ultra_valid'; schemaIndex = 0; shape = 'valid'; expected = 'pass' },
        [pscustomobject][ordered]@{ id = 'vilage_valid'; schemaIndex = 1; shape = 'valid'; expected = 'pass' },
        [pscustomobject][ordered]@{ id = 'provider_error'; schemaIndex = 0; shape = 'provider_error'; expected = 'provider_error' },
        [pscustomobject][ordered]@{ id = 'missing_field'; schemaIndex = 0; shape = 'missing_field'; expected = 'required_schema_missing' },
        [pscustomobject][ordered]@{ id = 'missing_category'; schemaIndex = 1; shape = 'missing_category'; expected = 'required_category_missing' },
        [pscustomobject][ordered]@{ id = 'malformed_json'; schemaIndex = 1; shape = 'malformed'; expected = 'malformed_json' },
        [pscustomobject][ordered]@{ id = 'base_echo_mismatch'; schemaIndex = 0; shape = 'base_mismatch'; expected = 'base_echo_mismatch' },
        [pscustomobject][ordered]@{ id = 'pagination_incomplete'; schemaIndex = 1; shape = 'pagination'; expected = 'pagination_incomplete' },
        [pscustomobject][ordered]@{ id = 'precip_null_allowed'; schemaIndex = 0; shape = 'precip_null'; expected = 'pass' },
        [pscustomobject][ordered]@{ id = 'optional_string_category_allowed'; schemaIndex = 1; shape = 'optional_string'; expected = 'pass' },
        [pscustomobject][ordered]@{ id = 'sentinel_rejected'; schemaIndex = 1; shape = 'sentinel'; expected = 'missing_or_sentinel_value' },
        [pscustomobject][ordered]@{ id = 'empty_rejected'; schemaIndex = 0; shape = 'empty'; expected = 'required_schema_missing' }
    )
    $rows = @()
    $unhandledCount = 0
    foreach ($fixture in $fixtures) {
        try {
            $schema = $EndpointSchemas[$fixture.schemaIndex]
            $body = if ($fixture.shape -eq 'provider_error') {
                New-SyntheticKmaBody -Schema $schema -ProviderCode '03'
            }
            elseif ($fixture.shape -eq 'missing_field') {
                New-SyntheticKmaBody -Schema $schema -MissingField
            }
            elseif ($fixture.shape -eq 'missing_category') {
                New-SyntheticKmaBody -Schema $schema -MissingCategory
            }
            elseif ($fixture.shape -eq 'malformed') {
                '{'
            }
            elseif ($fixture.shape -eq 'base_mismatch') {
                New-SyntheticKmaBody -Schema $schema -BaseMismatch
            }
            elseif ($fixture.shape -eq 'pagination') {
                New-SyntheticKmaBody -Schema $schema -PaginationIncomplete
            }
            elseif ($fixture.shape -eq 'precip_null') {
                New-SyntheticKmaBody -Schema $schema -ValueMode precip_null
            }
            elseif ($fixture.shape -eq 'optional_string') {
                New-SyntheticKmaBody -Schema $schema -OptionalStringCategory
            }
            elseif ($fixture.shape -eq 'sentinel') {
                New-SyntheticKmaBody -Schema $schema -ValueMode sentinel
            }
            elseif ($fixture.shape -eq 'empty') {
                New-SyntheticKmaBody -Schema $schema -ValueMode empty
            }
            else {
                New-SyntheticKmaBody -Schema $schema
            }
            $fixturePlan = New-SyntheticEndpointPlan -Schema $schema
            $validation = ConvertTo-SafeKmaValidation -Body $body -Schema $schema -EndpointPlan $fixturePlan `
                -FetchedAt '2026-08-10T12:00:00+09:00' -PlanC11BindingVerified $true
            $actual = if ($validation.c01 -eq 'pass') { 'pass' } else { [string]$validation.errorClass }
            $rows += [pscustomobject][ordered]@{
                id = $fixture.id
                endpointId = $schema.id
                actual = $actual
                expected = $fixture.expected
                match = ($actual -ceq $fixture.expected)
            }
        }
        catch {
            $unhandledCount++
            $rows += [pscustomobject][ordered]@{
                id = $fixture.id
                endpointId = 'not_evaluated'
                actual = 'fixture_unhandled'
                expected = $fixture.expected
                match = $false
            }
        }
        finally {
            $body = $null
            $validation = $null
            $fixturePlan = $null
        }
    }
    $descriptor = $fixtures | ConvertTo-Json -Depth 5 -Compress
    $projection = $rows | ConvertTo-Json -Depth 5 -Compress
    return [pscustomobject][ordered]@{
        validatorId = $Contract.ValidatorId
        fixtureCount = $fixtures.Count
        fixtureDescriptorSha256 = Get-TextSha256 -Text $descriptor
        resultProjectionSha256 = Get-TextSha256 -Text $projection
        allExpected = (@($rows | Where-Object { -not $_.match }).Count -eq 0)
        unhandledCount = $unhandledCount
    }
}

function Get-SanitizedExceptionRecord {
    param([AllowNull()][Exception]$Exception)

    $httpStatus = $null
    $webExceptionStatus = $null
    $chainTruncated = $false
    $responseDisposeSucceeded = $true
    $current = $Exception
    $depth = 0
    while ($null -ne $current) {
        if ($depth -gt 5) {
            $chainTruncated = $true
            break
        }
        if ($current -is [Net.WebException] -and $null -eq $webExceptionStatus) {
            $webExceptionStatus = $current.Status.ToString()
            try {
                if ($null -ne $current.Response) {
                    if ($current.Response -is [Net.HttpWebResponse]) {
                        $httpStatus = [int]([Net.HttpWebResponse]$current.Response).StatusCode
                    }
                    $current.Response.Dispose()
                }
            }
            catch {
                $responseDisposeSucceeded = $false
            }
        }
        $current = $current.InnerException
        $depth++
    }
    return [pscustomobject][ordered]@{
        httpStatus = $httpStatus
        webExceptionStatus = $webExceptionStatus
        chainTruncated = $chainTruncated
        responseDisposeSucceeded = $responseDisposeSucceeded
    }
}

function Get-ParameterValue {
    param(
        [Parameter(Mandatory = $true)]$EndpointPlan,
        [Parameter(Mandatory = $true)][string]$Name
    )

    foreach ($pair in @($EndpointPlan.parameters)) {
        if ([string]$pair[0] -ceq $Name) { return [string]$pair[1] }
    }
    return $null
}

function Test-EndpointPlan {
    param(
        [Parameter(Mandatory = $true)]$EndpointPlan,
        [Parameter(Mandatory = $true)]$Schema
    )

    if (-not (Test-ExactPropertySet -Object $EndpointPlan -Expected $ExpectedEndpointPlanProperties)) {
        return $false
    }
    if ([string]$EndpointPlan.id -cne [string]$Schema.id -or
        [string]$EndpointPlan.endpointPath -cne [string]$Schema.servicePath -or
        [string]$EndpointPlan.schemaId -cne [string]$Schema.schemaId) {
        return $false
    }
    $expectedNames = @('pageNo','numOfRows','dataType','base_date','base_time','nx','ny')
    $pairs = @($EndpointPlan.parameters)
    if ($pairs.Count -ne $expectedNames.Count) { return $false }
    for ($index = 0; $index -lt $expectedNames.Count; $index++) {
        if (@($pairs[$index]).Count -ne 2 -or [string]$pairs[$index][0] -cne $expectedNames[$index]) {
            return $false
        }
    }
    $queryOrder = [string]::Join('|', @($EndpointPlan.queryParameterOrder))
    if ($queryOrder -cne 'serviceKey|pageNo|numOfRows|dataType|base_date|base_time|nx|ny') {
        return $false
    }
    if ([string](Get-ParameterValue -EndpointPlan $EndpointPlan -Name 'pageNo') -cne '1' -or
        [string](Get-ParameterValue -EndpointPlan $EndpointPlan -Name 'numOfRows') -cne '1000' -or
        [string](Get-ParameterValue -EndpointPlan $EndpointPlan -Name 'dataType') -cne 'JSON' -or
        [string](Get-ParameterValue -EndpointPlan $EndpointPlan -Name 'nx') -cne [string]$Contract.TargetNx -or
        [string](Get-ParameterValue -EndpointPlan $EndpointPlan -Name 'ny') -cne [string]$Contract.TargetNy) {
        return $false
    }
    $baseDate = Get-ParameterValue -EndpointPlan $EndpointPlan -Name 'base_date'
    $baseTime = Get-ParameterValue -EndpointPlan $EndpointPlan -Name 'base_time'
    if ($baseDate -notmatch '^[0-9]{8}$' -or $baseTime -notmatch $Schema.baseTimePattern -or
        [string]$baseDate -cne [string]$Schema.expectedBaseDate -or
        [string]$baseTime -cne [string]$Schema.expectedBaseTime) {
        return $false
    }
    if ([string]::Join('|', @($EndpointPlan.requiredFields)) -cne [string]::Join('|', @($Schema.requiredFields))) {
        return $false
    }
    if ([string]::Join('|', @($EndpointPlan.requiredCategories)) -cne [string]::Join('|', @($Schema.requiredCategories))) {
        return $false
    }
    if ([string]$EndpointPlan.sourceUrl -cne [string]$Schema.sourceUrl -or
        $null -ne $EndpointPlan.sourceId -or
        [string]$EndpointPlan.licenseRegisterId -cne $Contract.LicenseRegisterId -or
        [string]$EndpointPlan.termsUrl -cne $Contract.TermsUrl -or
        [string]$EndpointPlan.termsEvidenceProjectionSha256 -cne $Contract.TermsEvidenceProjectionSha256 -or
        [string]::IsNullOrWhiteSpace([string]$EndpointPlan.termsEvidenceProjection) -or
        (Get-TextSha256 -Text ([string]$EndpointPlan.termsEvidenceProjection)) -cne $Contract.TermsEvidenceProjectionSha256 -or
        [string]$EndpointPlan.timePolicy -cne 'issued_base_echo_observed_null_valid_from_fcst_valid_until_null' -or
        [string]$EndpointPlan.locationPolicy -cne 'public_grid_request_context' -or
        [string]$EndpointPlan.unitApplicability -cne 'field_level' -or
        [string]$EndpointPlan.attributionTemplateId -cne $Contract.AttributionTemplateId -or
        [string]::Join('|', @($EndpointPlan.attributionRequiredTokens)) -cne 'sourceReference|sourceTime|fetchedAt' -or
        [string]$EndpointPlan.layerPolicy -cne 'immutable_original_and_derived_separated') {
        return $false
    }
    $planUnits = @($EndpointPlan.units)
    if ($planUnits.Count -ne $Schema.units.Count) { return $false }
    for ($unitIndex = 0; $unitIndex -lt $Schema.units.Count; $unitIndex++) {
        if (@($planUnits[$unitIndex]).Count -ne 2 -or
            [string]$planUnits[$unitIndex][0] -cne [string]$Schema.units[$unitIndex][0] -or
            [string]$planUnits[$unitIndex][1] -cne [string]$Schema.units[$unitIndex][1]) {
            return $false
        }
    }
    return $true
}

function Read-And-TestCanonicalPlan {
    param(
        [Parameter(Mandatory = $true)][string]$PlanPath,
        [Parameter(Mandatory = $true)][string]$ExpectedHash,
        [Parameter(Mandatory = $true)][string]$ScriptHash,
        [Parameter(Mandatory = $true)]$OfflineMatrix
    )

    $failure = [pscustomobject][ordered]@{
        pass = $false
        hashMatch = $false
        contractMatch = $false
        controlsMatch = $false
        securityMatch = $false
        scriptMatch = $false
        plan = $null
        computedHash = $null
    }
    if ($ExpectedHash -notmatch '^[0-9a-f]{64}$' -or -not [IO.File]::Exists($PlanPath)) {
        return $failure
    }
    try {
        $bytes = [IO.File]::ReadAllBytes($PlanPath)
        $computedHash = Get-BytesSha256 -Bytes $bytes
        $failure.computedHash = $computedHash
        $failure.hashMatch = ($computedHash -ceq $ExpectedHash)
        $hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
        $hasCr = (@($bytes | Where-Object { $_ -eq 0x0D }).Count -gt 0)
        $lfCount = @($bytes | Where-Object { $_ -eq 0x0A }).Count
        $hasNonAscii = (@($bytes | Where-Object { $_ -gt 0x7F }).Count -gt 0)
        if (-not $failure.hashMatch -or $hasBom -or $hasCr -or $hasNonAscii -or
            $bytes.Length -lt 2 -or $lfCount -ne 1 -or $bytes[$bytes.Length - 1] -ne 0x0A) {
            return $failure
        }
        $encoding = New-Object Text.UTF8Encoding($false, $true)
        $text = $encoding.GetString($bytes)
        $jsonText = $text.Substring(0, $text.Length - 1)
        if ($jsonText.Trim() -cne $jsonText -or $jsonText.Length -eq 0) { return $failure }
        $plan = ConvertFrom-Json -InputObject $jsonText
        if (-not (Test-ExactPropertySet -Object $plan -Expected $ExpectedPlanProperties)) { return $failure }
        $failure.plan = $plan

        $failure.scriptMatch = (
            [string]$plan.scriptPath -ceq $Contract.ScriptRelativePath -and
            [string]$plan.scriptSha256 -ceq $ScriptHash -and
            [string]$plan.scriptEncoding -ceq 'utf8_no_bom_lf_ascii_compatible' -and
            [string]$plan.scriptHashMode -ceq 'raw_file_bytes'
        )
        $endpointPlans = @($plan.endpoints)
        $endpointsMatch = ($endpointPlans.Count -eq $EndpointSchemas.Count)
        if ($endpointsMatch) {
            for ($index = 0; $index -lt $EndpointSchemas.Count; $index++) {
                if (-not (Test-EndpointPlan -EndpointPlan $endpointPlans[$index] -Schema $EndpointSchemas[$index])) {
                    $endpointsMatch = $false
                    break
                }
            }
        }

        $failure.contractMatch = (
            [string]$plan.schemaVersion -ceq $Contract.SchemaVersion -and
            [string]$plan.planId -ceq $Contract.PlanId -and
            [string]$plan.runId -ceq $Contract.RunId -and
            [string]$plan.parentPlanId -ceq $Contract.ParentPlanId -and
            [string]$plan.parentRunId -ceq $Contract.ParentRunId -and
            [string]$plan.parentPlanSha256 -ceq $Contract.ParentPlanSha256 -and
            [string]$plan.parentManifestSha256 -ceq $Contract.ParentManifestSha256 -and
            [string]$plan.parentOutcome -ceq $Contract.ParentOutcome -and
            [string]$plan.resumptionReason -ceq $Contract.ResumptionReason -and
            [string]$plan.fixedAt -ceq $Contract.FixedAt -and
            [string]$plan.budgetDate -ceq $Contract.BudgetDate -and
            [string]$plan.budgetTimezone -ceq 'Asia/Seoul' -and
            [string]$plan.ownerApproval -ceq $Contract.OwnerApproval -and
            [string]$plan.scheme -ceq $Contract.Scheme -and
            [string]$plan.host -ceq $Contract.Host -and
            [string]$plan.method -ceq 'GET' -and
            [string]$plan.requestBody -ceq 'none' -and
            [string]$plan.c11EvaluationMode -ceq $Contract.C11EvaluationMode -and
            $endpointsMatch
        )
        $decompression = [string]::Join('|', @($plan.automaticDecompression))
        $failure.controlsMatch = (
            [string]$plan.transport -ceq 'HttpWebRequest' -and
            [string]$plan.executionMode -ceq 'local_sentinel' -and
            [int]$plan.sentinelCalls -eq 2 -and
            [int]$plan.networkCallUpperBound -eq $Contract.NetworkCallUpperBound -and
            [int]$plan.networkCallSiteUpperBound -eq 1 -and
            [int]$plan.retry -eq 0 -and [int]$plan.parallel -eq 0 -and [int]$plan.redirect -eq 0 -and
            [int]$plan.timeoutSeconds -eq 15 -and [int]$plan.readWriteTimeoutSeconds -eq 15 -and
            [int]$plan.responseLimitBytes -eq $Contract.ResponseLimitBytes -and
            $decompression -ceq 'GZip|Deflate' -and -not [bool]$plan.keepAlive -and
            [int]$plan.requestIntervalMilliseconds -eq $Contract.InterCallDelayMilliseconds -and
            [int]$plan.preCallCount -eq $Contract.PreCallCount -and
            [int]$plan.expectedPostCallCount -eq $Contract.ExpectedPostCallCount -and
            [int]$plan.expectedPostCallCount -eq ([int]$plan.preCallCount + 2) -and
            [int]$plan.hardCap -eq $Contract.HardCap -and
            [int]$plan.expectedPostCallCount -le [int]$plan.hardCap -and
            [bool]$plan.processIsolation -and [bool]$plan.stopOnTransportOrSecurityFailure -and
            [int]$plan.validatorFixtureCount -eq [int]$OfflineMatrix.fixtureCount -and
            [string]$plan.validatorFixtureDescriptorSha256 -ceq [string]$OfflineMatrix.fixtureDescriptorSha256 -and
            [string]$plan.validatorResultProjectionSha256 -ceq [string]$OfflineMatrix.resultProjectionSha256
        )
        $c12Scope = [string]::Join('|', @($plan.c12Scope))
        $c12Representations = [string]::Join('|', @($plan.c12Representations))
        $failure.securityMatch = (
            [string]$plan.keyParameter -ceq $Contract.KeyParameter -and
            [string]$plan.keySource -ceq 'windows_current_user_dpapi_external_to_repo' -and
            [bool]$plan.sameUserSidRequired -and [bool]$plan.secretPathOutsideRepoAndOneDriveRequired -and
            [bool]$plan.secretNoReparseRequired -and [bool]$plan.secretMetadataGateBeforeImport -and
            [string]$plan.keyEncoding -ceq 'decode_then_EscapeDataString_once' -and
            [int]$plan.serviceKeyCountRequired -eq 1 -and [bool]$plan.keyRoundTripRequired -and
            [bool]$plan.prePostC12 -and $c12Scope -ceq 'tracked|untracked|environment' -and
            $c12Representations -ceq 'raw|url_encoded_once' -and
            [bool]$plan.c12ScanErrorsMustBeZero -and [bool]$plan.abortOnC12NonZero -and
            [bool]$plan.runtimeOutputSecretScanRequired -and [bool]$plan.errorBufferClearRequired -and
            [bool]$plan.zeroFreeBstrRequired -and [bool]$plan.cleanupFailureMustBeFalse -and
            [string]$plan.consoleOutput -ceq 'single_sanitized_json_allowlist_only' -and
            -not [bool]$plan.rawResponseStorage -and -not [bool]$plan.fullUrlStorage -and
            -not [bool]$plan.exceptionTextStorage
        )
        $failure.pass = (
            $failure.hashMatch -and $failure.contractMatch -and $failure.controlsMatch -and
            $failure.securityMatch -and $failure.scriptMatch
        )
        $bytes = $null
        $text = $null
        $jsonText = $null
        return $failure
    }
    catch {
        return $failure
    }
}

function New-EmptyEndpointResult {
    param(
        [Parameter(Mandatory = $true)]$Schema,
        [Parameter(Mandatory = $true)][string]$Phase,
        [Parameter(Mandatory = $true)][string]$ErrorClass
    )

    return [ordered]@{
        endpointId = $Schema.id
        endpointPath = $Schema.endpointPath
        phase = $Phase
        networkCalls = 0
        httpStatus = $null
        providerCode = $null
        providerHeaderStatus = 'not_observed'
        jsonHeaderParse = 'not_observed'
        dataBodyStatus = 'not_observed'
        schemaStatus = 'not_observed'
        itemCount = 0
        missingRequiredFields = @()
        missingRequiredCategories = @()
        fieldSignature = @()
        gridMatch = $false
        baseTimeParseable = $false
        forecastTimeParseable = $false
        baseEchoMatch = $false
        paginationComplete = $false
        valueDomainPass = $false
        fetchedAt = $null
        observedAt = $null
        issuedAt = $null
        validFrom = $null
        validUntil = $null
        validUntilNullReason = 'official_interval_end_not_provided'
        regionGridX = $Contract.TargetNx
        regionGridY = $Contract.TargetNy
        unitApplicability = 'field_level'
        unitSignature = @()
        sourceUrlSha256 = $null
        sourceUrlMatch = $false
        sourceIdNull = $false
        licenseRegisterId = $null
        termsUrlSha256 = $null
        termsUrlMatch = $false
        termsEvidenceProjectionSha256 = $null
        termsEvidenceMatch = $false
        attributionTemplateId = $null
        attributionRequiredTokensPresent = $false
        attributionRenderedSha256 = $null
        immutableOriginalPresent = $false
        derivedLayerPresent = $false
        layersSeparated = $false
        c11CaptureComplete = $false
        responseBytes = 0
        sanitizedProjectionSha256 = $null
        localValidator = 'not_run'
        providerContractVerdict = 'not_evaluable'
        resultKind = 'not_run'
        errorClass = $ErrorClass
        c01 = 'not_run'
        c11 = 'not_run'
        retry = 0
        redirect = 0
        querySecretControlPass = $false
        runtimeSecretScanPass = $false
        cleanupPass = $false
        errorBufferCleared = $false
        rawResponseStored = $false
        fullUrlStored = $false
        exceptionTextStored = $false
    }
}

function Invoke-EndpointRequest {
    param(
        [Parameter(Mandatory = $true)]$Schema,
        [Parameter(Mandatory = $true)]$EndpointPlan,
        [Parameter(Mandatory = $true)][string]$PlainKey,
        [Parameter(Mandatory = $true)][string]$EncodedKey
    )

    $result = New-EmptyEndpointResult -Schema $Schema -Phase 'request_build' -ErrorClass 'request_not_sent'
    $networkCalls = 0
    $httpStatus = $null
    $body = $null
    $query = $null
    $fullUri = $null
    $request = $null
    $response = $null
    $responseStream = $null
    $pairs = $null
    $publicParameters = $null
    $exceptionRecord = $null
    $cleanupPass = $true
    $runtimeSecretScanPass = $false
    $querySecretControlPass = $false
    $errorBufferCleared = $false
    $stopRequired = $true

    try {
        $publicParameters = [ordered]@{}
        foreach ($pair in @($EndpointPlan.parameters)) {
            $publicParameters[[string]$pair[0]] = [string]$pair[1]
        }
        $pairs = New-Object 'System.Collections.Generic.List[string]'
        [void]$pairs.Add(('serviceKey={0}' -f $EncodedKey))
        foreach ($entry in $publicParameters.GetEnumerator()) {
            [void]$pairs.Add(('{0}={1}' -f
                [Uri]::EscapeDataString([string]$entry.Key),
                [Uri]::EscapeDataString([string]$entry.Value)))
        }
        $query = [string]::Join('&', $pairs)
        $serviceKeyCount = ([regex]::Matches($query, '(?:^|&)serviceKey=')).Count
        $querySecretControlPass = (
            $serviceKeyCount -eq 1 -and
            [Uri]::UnescapeDataString($EncodedKey) -ceq $PlainKey
        )
        if (-not $querySecretControlPass) {
            throw [IO.InvalidDataException]::new('query_secret_control_failed')
        }

        $fullUri = '{0}://{1}{2}?{3}' -f $Contract.Scheme, $Contract.Host, $Schema.servicePath, $query
        $request = [Net.HttpWebRequest]::Create($fullUri)
        $request.Method = 'GET'
        $request.Accept = 'application/json'
        $request.UserAgent = 'NowSignal-contract-smoke/1.0'
        $request.AllowAutoRedirect = $false
        $request.Timeout = $Contract.TimeoutMilliseconds
        $request.ReadWriteTimeout = $Contract.TimeoutMilliseconds
        $request.KeepAlive = $false
        $request.AutomaticDecompression = ([Net.DecompressionMethods]::GZip -bor [Net.DecompressionMethods]::Deflate)

        $result.phase = 'send'
        $networkCalls++
        $script:ObservedNetworkCalls++
        $response = [Net.HttpWebResponse]$request.GetResponse()
        $httpStatus = [int]$response.StatusCode
        if ($httpStatus -ge 300 -and $httpStatus -lt 400) {
            throw [Net.WebException]::new('redirect_blocked', [Net.WebExceptionStatus]::ProtocolError)
        }
        if ($response.ContentLength -gt $Contract.ResponseLimitBytes) {
            throw [IO.InvalidDataException]::new('response_limit_exceeded')
        }

        $result.phase = 'read'
        $responseStream = $response.GetResponseStream()
        $body = Read-LimitedUtf8 -Stream $responseStream -Limit $Contract.ResponseLimitBytes
        $fetchedAt = (Get-Date).ToString('yyyy-MM-ddTHH:mm:sszzz')
        $responseBytes = [Text.Encoding]::UTF8.GetByteCount($body)
        $result.phase = 'validate'
        $validation = ConvertTo-SafeKmaValidation -Body $body -Schema $Schema -EndpointPlan $EndpointPlan `
            -FetchedAt $fetchedAt -PlanC11BindingVerified $true
        $safeProjection = [string]::Join('|', @(
            $Schema.id,[string]$httpStatus,[string]$validation.providerCode,
            [string]$validation.itemCount,[string]$validation.schemaStatus,
            [string]$validation.gridMatch,[string]$validation.baseTimeParseable,
            [string]$validation.forecastTimeParseable,[string]$validation.baseEchoMatch,
            [string]$validation.paginationComplete,[string]$validation.valueDomainPass,
            [string]$validation.c01,[string]$validation.c11,
            [string]$validation.sourceUrlSha256,[string]$validation.termsUrlSha256,
            [string]$validation.termsEvidenceProjectionSha256,[string]$validation.attributionRenderedSha256
        ) + @($validation.fieldSignature) + @($validation.unitSignature) + @('MISSING_FIELDS') +
            @($validation.missingRequiredFields) + @('MISSING_CATEGORIES') +
            @($validation.missingRequiredCategories))

        $result.phase = 'completed'
        $result.networkCalls = $networkCalls
        $result.httpStatus = $httpStatus
        $result.providerCode = $validation.providerCode
        $result.providerHeaderStatus = $validation.providerHeaderStatus
        $result.jsonHeaderParse = $validation.jsonHeaderParse
        $result.dataBodyStatus = $validation.dataBodyStatus
        $result.schemaStatus = $validation.schemaStatus
        $result.itemCount = $validation.itemCount
        $result.missingRequiredFields = @($validation.missingRequiredFields)
        $result.missingRequiredCategories = @($validation.missingRequiredCategories)
        $result.fieldSignature = @($validation.fieldSignature)
        $result.gridMatch = $validation.gridMatch
        $result.baseTimeParseable = $validation.baseTimeParseable
        $result.forecastTimeParseable = $validation.forecastTimeParseable
        $result.baseEchoMatch = $validation.baseEchoMatch
        $result.paginationComplete = $validation.paginationComplete
        $result.valueDomainPass = $validation.valueDomainPass
        $result.fetchedAt = $validation.fetchedAt
        $result.observedAt = $validation.observedAt
        $result.issuedAt = $validation.issuedAt
        $result.validFrom = $validation.validFrom
        $result.validUntil = $validation.validUntil
        $result.validUntilNullReason = $validation.validUntilNullReason
        $result.regionGridX = $validation.regionGridX
        $result.regionGridY = $validation.regionGridY
        $result.unitApplicability = $validation.unitApplicability
        $result.unitSignature = @($validation.unitSignature)
        $result.sourceUrlSha256 = $validation.sourceUrlSha256
        $result.sourceUrlMatch = $validation.sourceUrlMatch
        $result.sourceIdNull = $validation.sourceIdNull
        $result.licenseRegisterId = $validation.licenseRegisterId
        $result.termsUrlSha256 = $validation.termsUrlSha256
        $result.termsUrlMatch = $validation.termsUrlMatch
        $result.termsEvidenceProjectionSha256 = $validation.termsEvidenceProjectionSha256
        $result.termsEvidenceMatch = $validation.termsEvidenceMatch
        $result.attributionTemplateId = $validation.attributionTemplateId
        $result.attributionRequiredTokensPresent = $validation.attributionRequiredTokensPresent
        $result.attributionRenderedSha256 = $validation.attributionRenderedSha256
        $result.immutableOriginalPresent = $validation.immutableOriginalPresent
        $result.derivedLayerPresent = $validation.derivedLayerPresent
        $result.layersSeparated = $validation.layersSeparated
        $result.c11CaptureComplete = $validation.c11CaptureComplete
        $result.responseBytes = $responseBytes
        $result.sanitizedProjectionSha256 = Get-TextSha256 -Text $safeProjection
        $result.localValidator = 'pass'
        $result.providerContractVerdict = if ($validation.c01 -eq 'pass') { 'pass' } else { 'fail' }
        $result.resultKind = $validation.resultKind
        $result.errorClass = $validation.errorClass
        $result.c01 = $validation.c01
        $result.c11 = $validation.c11
        $result.querySecretControlPass = $querySecretControlPass
        $stopRequired = (
            $httpStatus -ne 200 -or $validation.providerCode -ne '00'
        )
        $validation = $null
        $safeProjection = $null
    }
    catch {
        try {
            $exceptionRecord = Get-SanitizedExceptionRecord -Exception $_.Exception
            if (-not $exceptionRecord.responseDisposeSucceeded) { $cleanupPass = $false }
            if ($null -ne $exceptionRecord.httpStatus) { $httpStatus = [int]$exceptionRecord.httpStatus }
            $errorClass = if ($networkCalls -eq 0) {
                'request_build_error'
            }
            elseif ($httpStatus -eq 401) {
                'http_unauthorized_unclassified'
            }
            elseif ($httpStatus -eq 403) {
                'http_forbidden_unclassified'
            }
            elseif ($httpStatus -eq 429) {
                'rate_limited'
            }
            elseif ($null -ne $httpStatus -and $httpStatus -ge 500) {
                'provider_unavailable'
            }
            elseif ($exceptionRecord.webExceptionStatus -eq 'Timeout') {
                'client_timeout'
            }
            elseif ($result.phase -eq 'read') {
                'response_read_error'
            }
            else {
                'transport_error_unclassified'
            }
            $result.networkCalls = $networkCalls
            $result.httpStatus = $httpStatus
            $result.errorClass = $errorClass
            $result.resultKind = if ($networkCalls -eq 0) { 'not_run' } else { 'unavailable' }
            $result.c01 = if ($networkCalls -eq 0) { 'not_run' } else { 'fail' }
            $result.localValidator = if ($result.phase -eq 'validate') { 'fail' } else { 'not_run' }
            $result.querySecretControlPass = $querySecretControlPass
            $stopRequired = $true
        }
        catch {
            $cleanupPass = $false
            $result = New-EmptyEndpointResult -Schema $Schema -Phase 'exception_sanitize' -ErrorClass 'sanitized_exception_handler_error'
            $result.networkCalls = $networkCalls
            $result.resultKind = if ($networkCalls -eq 0) { 'not_run' } else { 'unavailable' }
            $result.c01 = if ($networkCalls -eq 0) { 'not_run' } else { 'fail' }
            $stopRequired = $true
        }
    }
    finally {
        try {
            $candidate = [pscustomobject]$result | ConvertTo-Json -Depth 6 -Compress
            $encodedLower = [regex]::Replace(
                $EncodedKey,
                '%[0-9A-F]{2}',
                { param($match) $match.Value.ToLowerInvariant() }
            )
            $occurrences = (
                (Get-OccurrenceCount -Text $candidate -Needle $PlainKey) +
                (Get-OccurrenceCount -Text $candidate -Needle $EncodedKey) +
                (Get-OccurrenceCount -Text $candidate -Needle $encodedLower)
            )
            if ($null -ne $fullUri) { $occurrences += Get-OccurrenceCount -Text $candidate -Needle $fullUri }
            if ($null -ne $body -and $body.Length -gt 0) { $occurrences += Get-OccurrenceCount -Text $candidate -Needle $body }
            $runtimeSecretScanPass = (
                $occurrences -eq 0 -and $candidate -notmatch 'https?://' -and
                $candidate -notmatch '(?i)serviceKey=' -and $candidate -notmatch 'S-1-[0-9-]+' -and
                $candidate -notmatch '\\Users\\' -and $candidate -notmatch '\\OneDrive\\'
            )
            $candidate = $null
            $encodedLower = $null
        }
        catch {
            $runtimeSecretScanPass = $false
        }
        try { if ($null -ne $responseStream) { $responseStream.Dispose() } } catch { $cleanupPass = $false }
        try { if ($null -ne $response) { $response.Dispose() } } catch { $cleanupPass = $false }
        try { if ($null -ne $pairs) { $pairs.Clear() } } catch { $cleanupPass = $false }
        try { if ($null -ne $publicParameters) { $publicParameters.Clear() } } catch { $cleanupPass = $false }
        $body = $null
        $query = $null
        $fullUri = $null
        $request = $null
        $response = $null
        $responseStream = $null
        $pairs = $null
        $publicParameters = $null
        $exceptionRecord = $null
        try {
            $Error.Clear()
            $errorBufferCleared = ($Error.Count -eq 0)
        }
        catch {
            $errorBufferCleared = $false
            $cleanupPass = $false
        }
        $result.runtimeSecretScanPass = $runtimeSecretScanPass
        $result.cleanupPass = $cleanupPass
        $result.errorBufferCleared = $errorBufferCleared
        if (-not $runtimeSecretScanPass -or -not $cleanupPass -or -not $errorBufferCleared) {
            $stopRequired = $true
        }
    }
    return [pscustomobject][ordered]@{
        publicResult = [pscustomobject]$result
        stopRequired = $stopRequired
    }
}

function Test-SafeOutputRecord {
    param([Parameter(Mandatory = $true)]$Record)

    $allowedTop = @(
        'mode','planId','runId','evaluatedAt','phase','networkCalls','endpointCount',
        'endpointResults','retry','redirect','parallel','interCallDelayMilliseconds',
        'rawResponseStored','fullUrlStored','exceptionTextStored','planSha256','scriptSha256',
        'scriptHashBeforeMatch','scriptHashAfterMatch','preflightPlanHashMatch',
        'preflightPlanContractMatch','preflightPlanControlsMatch','preflightPlanSecurityMatch',
        'preflightScriptEncodingMatch','preflightBudgetDateMatch','preflightTimezoneMatch',
        'preflightSameUserOwnerSid','preflightSecretOutsideRepo','preflightSecretOutsideOneDrive',
        'preflightSecretNoReparse','preflightKeyRoundTrip','preflightOfflineMatrixPass',
        'preflightPass','nonSecretPreflightPass','c12PreRawRepo','c12PreEncodedRepo',
        'c12PreRawEnv','c12PreEncodedEnv','c12PreScanErrors','c12PostRawRepo',
        'c12PostEncodedRepo','c12PostRawEnv','c12PostEncodedEnv','c12PostScanErrors',
        'c12Pass','secretReferencesCleared','bstrZeroFreeSucceeded','errorBufferCleared',
        'cleanupFailure','runtimeSecretScanPass','outputAllowlistPass','securityConformance',
        'c01Verdict','c11Verdict','contractVerdict','planConformance','runClosed','cumulativeCalls'
    )
    $allowedEndpoint = @(
        'endpointId','endpointPath','phase','networkCalls','httpStatus','providerCode',
        'providerHeaderStatus','jsonHeaderParse','dataBodyStatus','schemaStatus','itemCount',
        'missingRequiredFields','missingRequiredCategories','fieldSignature','gridMatch',
        'baseTimeParseable','forecastTimeParseable','baseEchoMatch','paginationComplete',
        'valueDomainPass','fetchedAt','observedAt','issuedAt','validFrom','validUntil',
        'validUntilNullReason','regionGridX','regionGridY','unitApplicability','unitSignature',
        'sourceUrlSha256','sourceUrlMatch','sourceIdNull','licenseRegisterId','termsUrlSha256',
        'termsUrlMatch','termsEvidenceProjectionSha256','termsEvidenceMatch',
        'attributionTemplateId','attributionRequiredTokensPresent','attributionRenderedSha256',
        'immutableOriginalPresent','derivedLayerPresent','layersSeparated','c11CaptureComplete',
        'responseBytes','sanitizedProjectionSha256',
        'localValidator','providerContractVerdict','resultKind','errorClass','c01','retry',
        'c11','redirect','querySecretControlPass','runtimeSecretScanPass','cleanupPass',
        'errorBufferCleared','rawResponseStored','fullUrlStored','exceptionTextStored'
    )
    if (-not (Test-ExactPropertySet -Object $Record -Expected $allowedTop)) { return $false }
    foreach ($endpoint in @($Record.endpointResults)) {
        if (-not (Test-ExactPropertySet -Object $endpoint -Expected $allowedEndpoint)) { return $false }
    }
    $json = $Record | ConvertTo-Json -Depth 8 -Compress
    if ($json.Length -gt 65536 -or $json -match 'https?://' -or $json -match '(?i)serviceKey=' -or
        $json -match 'S-1-[0-9-]+' -or $json -match '\\Users\\' -or $json -match '\\OneDrive\\' -or
        $json.Contains($Contract.SyntheticMarker)) {
        return $false
    }
    return $true
}

$scriptHash = $null
$finalResult = $null

try {
    $scriptHash = Get-FileSha256 -Path $PSCommandPath
    if ($OfflineSelfTest -and -not $PlanPreflight -and -not $Execute) {
        $first = Invoke-OfflineValidatorMatrix
        $second = Invoke-OfflineValidatorMatrix
        $deterministic = (
            $first.fixtureDescriptorSha256 -ceq $second.fixtureDescriptorSha256 -and
            $first.resultProjectionSha256 -ceq $second.resultProjectionSha256
        )
        $finalResult = [ordered]@{
            mode = 'offline_self_test'
            validatorId = $Contract.ValidatorId
            scriptSha256 = $scriptHash
            fixtureCount = $first.fixtureCount
            fixtureDescriptorSha256 = $first.fixtureDescriptorSha256
            resultProjectionSha256 = $first.resultProjectionSha256
            allExpected = ($first.allExpected -and $second.allExpected)
            deterministic = $deterministic
            unhandledCount = $first.unhandledCount + $second.unhandledCount
            networkCalls = 0
            pass = (
                $first.allExpected -and $second.allExpected -and $deterministic -and
                $first.unhandledCount -eq 0 -and $second.unhandledCount -eq 0
            )
        }
        $offlineJson = $finalResult | ConvertTo-Json -Depth 5 -Compress
        if ($offlineJson.Contains($Contract.SyntheticMarker) -or $offlineJson -match 'https?://' -or
            $offlineJson -match '(?i)serviceKey=') {
            throw [Security.SecurityException]::new('offline_output_rejected')
        }
        $offlineJson
        if (-not $finalResult.pass) { exit 1 }
        exit 0
    }
    elseif ($PlanPreflight -and -not $OfflineSelfTest -and -not $Execute) {
        $repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
        $planPath = [IO.Path]::GetFullPath((Join-Path $repoRoot $Contract.PlanRelativePath))
        $offlineMatrix = Invoke-OfflineValidatorMatrix
        $planCheck = Read-And-TestCanonicalPlan -PlanPath $planPath -ExpectedHash $ExpectedPlanHash -ScriptHash $scriptHash -OfflineMatrix $offlineMatrix
        $pass = (
            $planCheck.pass -and $offlineMatrix.allExpected -and
            $offlineMatrix.unhandledCount -eq 0 -and $script:ObservedNetworkCalls -eq 0
        )
        $preflightResult = [ordered]@{
            mode = 'plan_preflight'
            planId = if ($pass) { $Contract.PlanId } else { $null }
            runId = if ($pass) { $Contract.RunId } else { $null }
            planSha256 = if ($pass) { [string]$ExpectedPlanHash } else { $null }
            scriptSha256 = $scriptHash
            hashMatch = $planCheck.hashMatch
            contractMatch = $planCheck.contractMatch
            controlsMatch = $planCheck.controlsMatch
            securityMatch = $planCheck.securityMatch
            scriptMatch = $planCheck.scriptMatch
            offlineMatrixPass = ($offlineMatrix.allExpected -and $offlineMatrix.unhandledCount -eq 0)
            networkCalls = 0
            pass = $pass
        }
        $preflightJson = [pscustomobject]$preflightResult | ConvertTo-Json -Compress
        if ($preflightJson -match 'https?://' -or $preflightJson -match '(?i)serviceKey=' -or
            $preflightJson.Contains($Contract.SyntheticMarker)) {
            throw [Security.SecurityException]::new('plan_preflight_output_rejected')
        }
        $preflightJson
        if (-not $pass) { exit 1 }
        exit 0
    }
    elseif ($Execute -and -not $OfflineSelfTest -and -not $PlanPreflight) {
        $repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
        $planPath = [IO.Path]::GetFullPath((Join-Path $repoRoot $Contract.PlanRelativePath))
        $secretPath = [IO.Path]::GetFullPath((
            Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) $Contract.SecretRelativePath
        ))
        $plan = $null
        $planCheck = $null
        $credential = $null
        $secureKey = $null
        $bstr = [IntPtr]::Zero
        $bstrAllocated = $false
        $bstrZeroFreeSucceeded = $false
        $plainKey = $null
        $encodedKey = $null
        $preC12 = $null
        $postC12 = $null
        $endpointResults = @()
        $networkCalls = 0
        $failureStage = 'plan_preflight'
        $cleanupFailure = $false
        $errorBufferCleared = $false
        $secretReferencesCleared = $false
        $runtimeSecretScanPass = $false
        $sameUserOwnerSid = $false
        $secretOutsideRepo = $false
        $secretOutsideOneDrive = $false
        $secretNoReparse = $false
        $keyRoundTrip = $false
        $preflightPass = $false
        $nonSecretPreflightPass = $false
        $budgetDateMatch = $false
        $timezoneMatch = $false
        $scriptEncodingMatch = $false
        $scriptHashAfter = $null
        $offlineMatrixPass = $false
        $planId = $null
        $runId = $null
        $safePlanHash = $null
        $stopwatch = [Diagnostics.Stopwatch]::StartNew()

        try {
            $offlineMatrix = Invoke-OfflineValidatorMatrix
            if ($ExpectedPlanHash -notmatch '^[0-9a-f]{64}$') {
                throw [IO.InvalidDataException]::new('expected_plan_hash_invalid')
            }
            $planCheck = Read-And-TestCanonicalPlan -PlanPath $planPath -ExpectedHash $ExpectedPlanHash -ScriptHash $scriptHash -OfflineMatrix $offlineMatrix
            if ($null -ne $planCheck.plan) {
                $plan = $planCheck.plan
            }
            if ($planCheck.pass) {
                $planId = [string]$plan.planId
                $runId = [string]$plan.runId
                $safePlanHash = [string]$ExpectedPlanHash
            }

            $scriptBytes = [IO.File]::ReadAllBytes($PSCommandPath)
            $scriptEncodingMatch = (
                -not ($scriptBytes.Length -ge 3 -and $scriptBytes[0] -eq 0xEF -and $scriptBytes[1] -eq 0xBB -and $scriptBytes[2] -eq 0xBF) -and
                @($scriptBytes | Where-Object { $_ -eq 0x0D }).Count -eq 0 -and
                @($scriptBytes | Where-Object { $_ -gt 0x7F }).Count -eq 0
            )
            $scriptBytes = $null
            $now = Get-Date
            if ($null -ne $plan) {
                $budgetDateMatch = (
                    $now.ToString('yyyy-MM-dd') -ceq [string]$plan.budgetDate -and
                    [int]$plan.expectedPostCallCount -le [int]$plan.hardCap
                )
            }
            $timezoneMatch = ($now.ToString('zzz') -ceq '+09:00')
            $offlineMatrixPass = ($offlineMatrix.allExpected -and $offlineMatrix.unhandledCount -eq 0)
            $nonSecretPreflightPass = (
                $planCheck.pass -and $scriptEncodingMatch -and $budgetDateMatch -and
                $timezoneMatch -and $offlineMatrixPass
            )
            if (-not $nonSecretPreflightPass) {
                throw [IO.InvalidDataException]::new('non_secret_preflight_failed')
            }

            if (-not [IO.File]::Exists($secretPath)) {
                throw [IO.FileNotFoundException]::new('secret_file_missing')
            }
            $secretOutsideRepo = -not $secretPath.StartsWith($repoRoot, [StringComparison]::OrdinalIgnoreCase)
            $secretOutsideOneDrive = $true
            foreach ($oneDriveName in @('OneDrive','OneDriveConsumer','OneDriveCommercial')) {
                try {
                    $oneDriveValue = [Environment]::GetEnvironmentVariable($oneDriveName)
                    if (-not [string]::IsNullOrWhiteSpace($oneDriveValue)) {
                        if (-not [IO.Path]::IsPathRooted($oneDriveValue)) {
                            $secretOutsideOneDrive = $false
                            continue
                        }
                        $oneDriveRoot = [IO.Path]::GetFullPath($oneDriveValue).TrimEnd([IO.Path]::DirectorySeparatorChar)
                        if ($secretPath -ceq $oneDriveRoot -or $secretPath.StartsWith(
                            $oneDriveRoot + [IO.Path]::DirectorySeparatorChar,
                            [StringComparison]::OrdinalIgnoreCase
                        )) { $secretOutsideOneDrive = $false }
                    }
                }
                catch { $secretOutsideOneDrive = $false }
            }
            $secretNoReparse = $true
            $cursor = Get-Item -LiteralPath $secretPath -Force
            for ($depth = 0; $depth -lt 16 -and $null -ne $cursor; $depth++) {
                if (($cursor.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
                    $secretNoReparse = $false
                }
                if ([string]$cursor.Name -match '^(?i)OneDrive(?:\s*-.*)?$') {
                    $secretOutsideOneDrive = $false
                }
                $cursor = if ($cursor -is [IO.FileInfo]) { $cursor.Directory } else { $cursor.Parent }
            }
            if ($null -ne $cursor) {
                $secretNoReparse = $false
                $secretOutsideOneDrive = $false
            }
            $currentSid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
            $ownerText = (Get-Acl -LiteralPath $secretPath).Owner
            try {
                $ownerSid = (New-Object Security.Principal.NTAccount($ownerText)).Translate(
                    [Security.Principal.SecurityIdentifier]
                ).Value
            }
            catch {
                $ownerSid = if ($ownerText -match '^S-1-') { $ownerText } else { $null }
            }
            $sameUserOwnerSid = ($null -ne $ownerSid -and $currentSid -ceq $ownerSid)
            $ownerText = $null
            $ownerSid = $null
            $currentSid = $null
            if (-not ($sameUserOwnerSid -and $secretOutsideRepo -and $secretOutsideOneDrive -and $secretNoReparse)) {
                throw [Security.SecurityException]::new('secret_metadata_preflight_failed')
            }

            $failureStage = 'secret_load'
            $credential = Import-Clixml -LiteralPath $secretPath
            if (-not ($credential -is [Management.Automation.PSCredential])) {
                throw [IO.InvalidDataException]::new('secret_type_invalid')
            }
            $secureKey = $credential.Password
            $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
            $bstrAllocated = ($bstr -ne [IntPtr]::Zero)
            if (-not $bstrAllocated) {
                throw [Security.SecurityException]::new('secret_bstr_allocation_failed')
            }
            $plainKey = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
            if ([string]::IsNullOrWhiteSpace($plainKey) -or $plainKey -notmatch '^[A-Za-z0-9+/=_-]+$') {
                throw [IO.InvalidDataException]::new('secret_shape_invalid')
            }
            $encodedKey = [Uri]::EscapeDataString($plainKey)
            $keyRoundTrip = ([Uri]::UnescapeDataString($encodedKey) -ceq $plainKey)
            if (-not $keyRoundTrip) {
                throw [Security.SecurityException]::new('key_roundtrip_failed')
            }

            $failureStage = 'c12_pre'
            $preC12 = Get-C12Counts -Raw $plainKey -Encoded $encodedKey -RepoRoot $repoRoot
            if (($preC12.rawRepo + $preC12.encodedRepo + $preC12.rawEnv + $preC12.encodedEnv + $preC12.scanErrors) -ne 0) {
                throw [Security.SecurityException]::new('c12_pre_failed')
            }
            $preflightPass = $true

            $failureStage = 'endpoint_1'
            $firstCall = Invoke-EndpointRequest -Schema $EndpointSchemas[0] -EndpointPlan @($plan.endpoints)[0] -PlainKey $plainKey -EncodedKey $encodedKey
            $endpointResults += $firstCall.publicResult
            $networkCalls += [int]$firstCall.publicResult.networkCalls
            if (-not $firstCall.stopRequired -and $networkCalls -lt $Contract.NetworkCallUpperBound) {
                [Threading.Thread]::Sleep($Contract.InterCallDelayMilliseconds)
                $failureStage = 'endpoint_2'
                $secondCall = Invoke-EndpointRequest -Schema $EndpointSchemas[1] -EndpointPlan @($plan.endpoints)[1] -PlainKey $plainKey -EncodedKey $encodedKey
                $endpointResults += $secondCall.publicResult
                $networkCalls += [int]$secondCall.publicResult.networkCalls
            }
        }
        catch {
            if ($endpointResults.Count -eq 0) {
                $preflightError = if ($failureStage -eq 'plan_preflight') {
                    'aborted_preflight'
                }
                elseif ($failureStage -eq 'secret_load') {
                    'secret_load_failed'
                }
                elseif ($failureStage -eq 'c12_pre') {
                    'c12_pre_failed'
                }
                else {
                    'execution_aborted'
                }
                $endpointResults = @()
            }
            else {
                $preflightError = 'endpoint_sequence_stopped'
            }
        }
        finally {
            try { $stopwatch.Stop() } catch { $cleanupFailure = $true }
            try {
                if ($null -ne $plainKey -and $null -ne $encodedKey) {
                    $postC12 = Get-C12Counts -Raw $plainKey -Encoded $encodedKey -RepoRoot $repoRoot
                }
            }
            catch {
                $postC12 = $null
                $cleanupFailure = $true
            }
            try {
                if ($bstrAllocated -and $bstr -ne [IntPtr]::Zero) {
                    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
                    $bstrZeroFreeSucceeded = $true
                    $bstr = [IntPtr]::Zero
                }
                elseif (-not $bstrAllocated) {
                    $bstrZeroFreeSucceeded = $true
                }
            }
            catch {
                $bstrZeroFreeSucceeded = $false
                $cleanupFailure = $true
            }
            $encodedKey = $null
            $plainKey = $null
            $secureKey = $null
            $credential = $null
            $secretReferencesCleared = (
                $bstrZeroFreeSucceeded -and $bstr -eq [IntPtr]::Zero -and
                $null -eq $encodedKey -and $null -eq $plainKey -and
                $null -eq $secureKey -and $null -eq $credential
            )
            try { $scriptHashAfter = Get-FileSha256 -Path $PSCommandPath } catch { $cleanupFailure = $true }
            try {
                $Error.Clear()
                $errorBufferCleared = ($Error.Count -eq 0)
            }
            catch {
                $errorBufferCleared = $false
                $cleanupFailure = $true
            }
        }

        $c12Pass = (
            $null -ne $preC12 -and $null -ne $postC12 -and
            ($preC12.rawRepo + $preC12.encodedRepo + $preC12.rawEnv + $preC12.encodedEnv + $preC12.scanErrors +
             $postC12.rawRepo + $postC12.encodedRepo + $postC12.rawEnv + $postC12.encodedEnv + $postC12.scanErrors) -eq 0
        )
        $endpointSecurityPass = (
            $endpointResults.Count -gt 0 -and
            @($endpointResults | Where-Object {
                -not $_.querySecretControlPass -or -not $_.runtimeSecretScanPass -or
                -not $_.cleanupPass -or -not $_.errorBufferCleared
            }).Count -eq 0
        )
        $runtimeSecretScanPass = $endpointSecurityPass
        $phase = if ($networkCalls -eq 2 -and $endpointResults.Count -eq 2) {
            'completed'
        }
        elseif ($networkCalls -eq 0) {
            'preflight_stopped'
        }
        else {
            'stopped'
        }
        $finalResult = [ordered]@{
            mode = 'execute'
            planId = $planId
            runId = $runId
            evaluatedAt = (Get-Date).ToString('yyyy-MM-ddTHH:mm:sszzz')
            phase = $phase
            networkCalls = $networkCalls
            endpointCount = $endpointResults.Count
            endpointResults = @($endpointResults)
            retry = 0
            redirect = 0
            parallel = 0
            interCallDelayMilliseconds = $Contract.InterCallDelayMilliseconds
            rawResponseStored = $false
            fullUrlStored = $false
            exceptionTextStored = $false
            planSha256 = $safePlanHash
            scriptSha256 = $scriptHash
            scriptHashBeforeMatch = ($null -ne $planCheck -and $planCheck.scriptMatch)
            scriptHashAfterMatch = ($scriptHashAfter -ceq $scriptHash)
            preflightPlanHashMatch = ($null -ne $planCheck -and $planCheck.hashMatch)
            preflightPlanContractMatch = ($null -ne $planCheck -and $planCheck.contractMatch)
            preflightPlanControlsMatch = ($null -ne $planCheck -and $planCheck.controlsMatch)
            preflightPlanSecurityMatch = ($null -ne $planCheck -and $planCheck.securityMatch)
            preflightScriptEncodingMatch = $scriptEncodingMatch
            preflightBudgetDateMatch = $budgetDateMatch
            preflightTimezoneMatch = $timezoneMatch
            preflightSameUserOwnerSid = $sameUserOwnerSid
            preflightSecretOutsideRepo = $secretOutsideRepo
            preflightSecretOutsideOneDrive = $secretOutsideOneDrive
            preflightSecretNoReparse = $secretNoReparse
            preflightKeyRoundTrip = $keyRoundTrip
            preflightOfflineMatrixPass = $offlineMatrixPass
            preflightPass = $preflightPass
            nonSecretPreflightPass = $nonSecretPreflightPass
            c12PreRawRepo = if ($null -eq $preC12) { $null } else { $preC12.rawRepo }
            c12PreEncodedRepo = if ($null -eq $preC12) { $null } else { $preC12.encodedRepo }
            c12PreRawEnv = if ($null -eq $preC12) { $null } else { $preC12.rawEnv }
            c12PreEncodedEnv = if ($null -eq $preC12) { $null } else { $preC12.encodedEnv }
            c12PreScanErrors = if ($null -eq $preC12) { $null } else { $preC12.scanErrors }
            c12PostRawRepo = if ($null -eq $postC12) { $null } else { $postC12.rawRepo }
            c12PostEncodedRepo = if ($null -eq $postC12) { $null } else { $postC12.encodedRepo }
            c12PostRawEnv = if ($null -eq $postC12) { $null } else { $postC12.rawEnv }
            c12PostEncodedEnv = if ($null -eq $postC12) { $null } else { $postC12.encodedEnv }
            c12PostScanErrors = if ($null -eq $postC12) { $null } else { $postC12.scanErrors }
            c12Pass = $c12Pass
            secretReferencesCleared = $secretReferencesCleared
            bstrZeroFreeSucceeded = $bstrZeroFreeSucceeded
            errorBufferCleared = $errorBufferCleared
            cleanupFailure = $cleanupFailure
            runtimeSecretScanPass = $runtimeSecretScanPass
            outputAllowlistPass = $false
            securityConformance = 'fail'
            c01Verdict = if ($endpointResults.Count -eq 0) { 'not_run' } elseif (
                $endpointResults.Count -eq 2 -and @($endpointResults | Where-Object { $_.c01 -cne 'pass' }).Count -eq 0
            ) { 'pass' } else { 'fail' }
            c11Verdict = if ($endpointResults.Count -eq 0) { 'not_run' } else { 'not_evaluated' }
            contractVerdict = 'fail'
            planConformance = 'fail'
            runClosed = $true
            cumulativeCalls = if ($null -eq $plan) { $networkCalls } else { [int]$plan.preCallCount + $networkCalls }
        }
        $initialAllowlistPass = Test-SafeOutputRecord -Record ([pscustomobject]$finalResult)
        $finalResult.outputAllowlistPass = $initialAllowlistPass
        $finalResult.securityConformance = if (
            $preflightPass -and $c12Pass -and $secretReferencesCleared -and
            $bstrZeroFreeSucceeded -and $errorBufferCleared -and -not $cleanupFailure -and
            $runtimeSecretScanPass -and $initialAllowlistPass -and
            $scriptHashAfter -ceq $scriptHash -and $networkCalls -le 2
        ) { 'pass' } else { 'fail' }
        $finalResult.contractVerdict = if ($finalResult.c01Verdict -ceq 'pass') { 'pass' } else { 'fail' }
        $finalResult.planConformance = if (
            $networkCalls -eq 2 -and $endpointResults.Count -eq 2 -and
            $finalResult.retry -eq 0 -and $finalResult.redirect -eq 0 -and
            $finalResult.parallel -eq 0 -and $finalResult.securityConformance -ceq 'pass' -and
            $finalResult.contractVerdict -ceq 'pass'
        ) { 'pass' } else { 'fail' }
        if (-not (Test-SafeOutputRecord -Record ([pscustomobject]$finalResult))) {
            throw [Security.SecurityException]::new('final_output_rejected')
        }
        $finalJson = [pscustomobject]$finalResult | ConvertTo-Json -Depth 8 -Compress
        $finalJson
        if ($finalResult.planConformance -cne 'pass') { exit 1 }
        exit 0
    }
    else {
        $failure = [ordered]@{
            mode = 'usage_error'
            errorClass = 'select_exactly_one_mode'
            networkCalls = 0
            pass = $false
        }
        $failure | ConvertTo-Json -Compress
        exit 1
    }
}
catch {
    $failure = [ordered]@{
        mode = 'sanitized_failure'
        errorClass = 'sanitized_top_level_failure'
        networkCalls = [int]$script:ObservedNetworkCalls
        pass = $false
    }
    $failure | ConvertTo-Json -Compress
    exit 1
}
