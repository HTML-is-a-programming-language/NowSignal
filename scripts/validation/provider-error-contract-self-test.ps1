param(
    [switch]$IncludeFixtureResults
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ClassifierId = 'provider-error-contract-classifier-v1'
$FixtureSourceClass = 'synthetic_classifier_fixture'
$ProviderProfile = 'airkorea-data-go-kr-synthetic-v1'
$FixedClock = '2026-08-10T00:00:00+09:00'
$ExceptionMaxDepth = 5
$SyntheticMarker = 'SYNTH_ONLY_DO_NOT_EMIT_7F4A9C'
$SyntheticUri = 'https://synthetic.invalid/path?serviceKey=' + $SyntheticMarker
$ExpectedFixtureIds = @(
    'c09_timeout_direct',
    'c09_timeout_wrapped_depth1',
    'c09_http_504_no_body',
    'c09_http_502',
    'c09_http_503',
    'c09_provider_05',
    'ambiguous_malformed_payload',
    'ambiguous_empty_payload',
    'c10_http_429_retry_after',
    'c10_http_429_no_retry_after',
    'c10_provider_quota_signal',
    'c10_daily_cap_precheck',
    'ambiguous_http_403',
    'ambiguous_truncated_chain',
    'conflicting_504_and_quota',
    'outside_success_header'
)
$ExpectedDescriptorSha256 = '633ece25bc6ad528db967a2f3d35a86c8402562df5cd8a9eb7d7b62486a050f4'
$ExpectedProjectionSha256 = '0a396ff4d4c68397f9a499a8c207c7649bf54d7fab81cf48b51fbddfa23677b2'

function Get-TextSha256 {
    param([Parameter(Mandatory = $true)][string]$Text)

    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $encoding = New-Object Text.UTF8Encoding($false)
        $bytes = $encoding.GetBytes($Text)
        $hash = $sha.ComputeHash($bytes)
        return ([BitConverter]::ToString($hash)).Replace('-', '').ToLowerInvariant()
    }
    finally {
        if ($null -ne $sha) {
            $sha.Dispose()
        }
    }
}

function Get-FileSha256 {
    param([Parameter(Mandatory = $true)][string]$Path)

    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $stream = [IO.File]::OpenRead($Path)
        try {
            $hash = $sha.ComputeHash($stream)
            return ([BitConverter]::ToString($hash)).Replace('-', '').ToLowerInvariant()
        }
        finally {
            if ($null -ne $stream) {
                $stream.Dispose()
            }
        }
    }
    finally {
        if ($null -ne $sha) {
            $sha.Dispose()
        }
    }
}

function New-SyntheticException {
    param(
        [Parameter(Mandatory = $true)][string]$Shape,
        [Parameter(Mandatory = $true)][string]$Marker,
        [Parameter(Mandatory = $true)][string]$UriMarker
    )

    $message = $Marker + ' ' + $UriMarker

    if ($Shape -eq 'none') {
        return $null
    }

    if ($Shape -eq 'timeout_direct') {
        return New-Object Net.WebException($message, [Net.WebExceptionStatus]::Timeout)
    }

    if ($Shape -eq 'timeout_wrapped_depth1') {
        $webException = New-Object Net.WebException($message, [Net.WebExceptionStatus]::Timeout)
        return New-Object Management.Automation.MethodInvocationException($message, $webException)
    }

    if ($Shape -eq 'timeout_beyond_depth_limit') {
        $current = New-Object Net.WebException($message, [Net.WebExceptionStatus]::Timeout)
        for ($index = 0; $index -lt 6; $index += 1) {
            $current = New-Object Exception($message, $current)
        }
        return $current
    }

    throw New-Object ArgumentException('Unknown synthetic exception shape')
}

function Get-SafeExceptionProjection {
    param(
        [AllowNull()][Exception]$Exception,
        [int]$MaxDepth = 5
    )

    if ($null -eq $Exception) {
        return [pscustomobject][ordered]@{
            outerClass = $null
            firstWebExceptionStatus = $null
            innerDepth = 0
            chainTruncated = $false
        }
    }

    $outerClass = $Exception.GetType().FullName
    $firstWebExceptionStatus = $null
    $current = $Exception
    $depth = 0
    $chainTruncated = $false

    while ($null -ne $current) {
        if ($depth -gt $MaxDepth) {
            $chainTruncated = $true
            break
        }

        if ($null -eq $firstWebExceptionStatus -and $current -is [Net.WebException]) {
            $firstWebExceptionStatus = $current.Status.ToString()
        }

        if ($null -eq $current.InnerException) {
            break
        }

        $current = $current.InnerException
        $depth += 1
    }

    return [pscustomobject][ordered]@{
        outerClass = $outerClass
        firstWebExceptionStatus = $firstWebExceptionStatus
        innerDepth = $depth
        chainTruncated = $chainTruncated
    }
}

function Get-SyntheticOutcomeClassification {
    param(
        [AllowNull()][Nullable[int]]$HttpStatus,
        [AllowNull()][string]$ProviderCode,
        [Parameter(Mandatory = $true)][string]$PayloadStatus,
        [Parameter(Mandatory = $true)][string]$QuotaSignal,
        [Parameter(Mandatory = $true)][bool]$RetryAfterPresent,
        [Parameter(Mandatory = $true)][int]$CurrentCalls,
        [Parameter(Mandatory = $true)][int]$DailyCap,
        [Parameter(Mandatory = $true)][pscustomobject]$ExceptionProjection
    )

    $c09Signals = @()
    $c10Signals = @()

    if ($CurrentCalls -ge $DailyCap) {
        $c10Signals += 'daily_cap_precheck'
    }

    if ($null -ne $HttpStatus) {
        if ($HttpStatus -eq 429) {
            $c10Signals += 'http_429'
        }
        elseif ($HttpStatus -eq 502 -or $HttpStatus -eq 503 -or $HttpStatus -eq 504) {
            $c09Signals += 'http_gateway_failure'
        }
    }

    if ($ProviderCode -eq '05') {
        $c09Signals += 'provider_timeout'
    }

    if ($QuotaSignal -eq 'provider_quota_exceeded' -or $QuotaSignal -eq 'provider_rate_limit_exceeded') {
        $c10Signals += 'provider_quota_signal'
    }

    if (
        -not $ExceptionProjection.chainTruncated -and
        $ExceptionProjection.firstWebExceptionStatus -eq 'Timeout'
    ) {
        $c09Signals += 'client_timeout'
    }

    if ($ExceptionProjection.chainTruncated -and $c09Signals.Count -eq 0 -and $c10Signals.Count -eq 0) {
        return [pscustomobject][ordered]@{
            caseId = 'not_classified'
            errorClass = 'exception_chain_truncated_unclassified'
            resultKind = 'unavailable'
            retryDisposition = 'manual_review'
            requestBlocked = $false
            retryAfterObserved = $RetryAfterPresent
            sameRunRetryAllowed = $false
            retryPolicyExecutionVerified = $false
            providerBehaviorVerified = $false
        }
    }

    if ($c09Signals.Count -gt 0 -and $c10Signals.Count -gt 0) {
        return [pscustomobject][ordered]@{
            caseId = 'not_classified'
            errorClass = 'conflicting_c09_c10_signals_unclassified'
            resultKind = 'unavailable'
            retryDisposition = 'manual_review'
            requestBlocked = ($CurrentCalls -ge $DailyCap)
            retryAfterObserved = $RetryAfterPresent
            sameRunRetryAllowed = $false
            retryPolicyExecutionVerified = $false
            providerBehaviorVerified = $false
        }
    }

    if ($c10Signals.Count -gt 0) {
        $errorClass = 'quota_or_rate_limit_exceeded'
        $retryDisposition = 'wait_for_budget_window'
        $requestBlocked = $false

        if ($CurrentCalls -ge $DailyCap) {
            $errorClass = 'daily_cap_precheck_blocked'
            $retryDisposition = 'wait_for_next_budget_day'
            $requestBlocked = $true
        }
        elseif ($null -ne $HttpStatus -and $HttpStatus -eq 429) {
            $errorClass = 'http_429_rate_limited'
            $retryDisposition = if ($RetryAfterPresent) {
                'retry_after_present_not_parsed'
            }
            else {
                'manual_budget_review'
            }
        }

        return [pscustomobject][ordered]@{
            caseId = 'C-10'
            errorClass = $errorClass
            resultKind = 'unavailable'
            retryDisposition = $retryDisposition
            requestBlocked = $requestBlocked
            retryAfterObserved = $RetryAfterPresent
            sameRunRetryAllowed = $false
            retryPolicyExecutionVerified = $false
            providerBehaviorVerified = $false
        }
    }

    if ($c09Signals.Count -gt 0) {
        $errorClass = 'backend_or_transport_unavailable'

        if ($null -ne $HttpStatus -and $HttpStatus -eq 504) {
            $errorClass = 'http_504_gateway_timeout_origin_unclassified'
        }
        elseif ($null -ne $HttpStatus -and ($HttpStatus -eq 502 -or $HttpStatus -eq 503)) {
            $errorClass = 'http_gateway_or_backend_unavailable'
        }
        elseif ($ProviderCode -eq '05') {
            $errorClass = 'provider_service_timeout'
        }
        elseif ($ExceptionProjection.firstWebExceptionStatus -eq 'Timeout') {
            $errorClass = 'client_timeout'
        }
        elseif ($PayloadStatus -eq 'malformed') {
            $errorClass = 'backend_payload_malformed'
        }
        elseif ($PayloadStatus -eq 'empty_backend_payload') {
            $errorClass = 'backend_payload_empty'
        }

        return [pscustomobject][ordered]@{
            caseId = 'C-09'
            errorClass = $errorClass
            resultKind = 'unavailable'
            retryDisposition = 'bounded_backoff_after_budget_check'
            requestBlocked = $false
            retryAfterObserved = $RetryAfterPresent
            sameRunRetryAllowed = $false
            retryPolicyExecutionVerified = $false
            providerBehaviorVerified = $false
        }
    }

    if ($PayloadStatus -eq 'malformed' -or $PayloadStatus -eq 'empty_backend_payload') {
        $payloadErrorClass = if ($PayloadStatus -eq 'malformed') {
            'malformed_payload_origin_unclassified'
        }
        else {
            'empty_payload_origin_unclassified'
        }

        return [pscustomobject][ordered]@{
            caseId = 'not_classified'
            errorClass = $payloadErrorClass
            resultKind = 'unavailable'
            retryDisposition = 'manual_review'
            requestBlocked = $false
            retryAfterObserved = $RetryAfterPresent
            sameRunRetryAllowed = $false
            retryPolicyExecutionVerified = $false
            providerBehaviorVerified = $false
        }
    }

    $fallbackClass = 'outside_c09_c10_scope'
    if ($null -ne $HttpStatus -and $HttpStatus -eq 403) {
        $fallbackClass = 'http_403_unclassified'
    }

    return [pscustomobject][ordered]@{
        caseId = 'not_classified'
        errorClass = $fallbackClass
        resultKind = 'not_evaluated'
        retryDisposition = 'manual_review'
        requestBlocked = $false
        retryAfterObserved = $RetryAfterPresent
        sameRunRetryAllowed = $false
        retryPolicyExecutionVerified = $false
        providerBehaviorVerified = $false
    }
}

function Get-Fixtures {
    return @(
        [pscustomobject][ordered]@{ id = 'c09_timeout_direct'; http = $null; code = $null; payload = 'not_observed'; quota = 'none'; retryAfter = $false; current = 0; cap = 100; exception = 'timeout_direct'; expectedCase = 'C-09'; expectedError = 'client_timeout'; expectedResult = 'unavailable'; expectedRetry = 'bounded_backoff_after_budget_check'; expectedBlocked = $false; expectedTruncated = $false },
        [pscustomobject][ordered]@{ id = 'c09_timeout_wrapped_depth1'; http = $null; code = $null; payload = 'not_observed'; quota = 'none'; retryAfter = $false; current = 0; cap = 100; exception = 'timeout_wrapped_depth1'; expectedCase = 'C-09'; expectedError = 'client_timeout'; expectedResult = 'unavailable'; expectedRetry = 'bounded_backoff_after_budget_check'; expectedBlocked = $false; expectedTruncated = $false },
        [pscustomobject][ordered]@{ id = 'c09_http_504_no_body'; http = 504; code = $null; payload = 'not_observed'; quota = 'none'; retryAfter = $false; current = 0; cap = 100; exception = 'none'; expectedCase = 'C-09'; expectedError = 'http_504_gateway_timeout_origin_unclassified'; expectedResult = 'unavailable'; expectedRetry = 'bounded_backoff_after_budget_check'; expectedBlocked = $false; expectedTruncated = $false },
        [pscustomobject][ordered]@{ id = 'c09_http_502'; http = 502; code = $null; payload = 'not_observed'; quota = 'none'; retryAfter = $false; current = 0; cap = 100; exception = 'none'; expectedCase = 'C-09'; expectedError = 'http_gateway_or_backend_unavailable'; expectedResult = 'unavailable'; expectedRetry = 'bounded_backoff_after_budget_check'; expectedBlocked = $false; expectedTruncated = $false },
        [pscustomobject][ordered]@{ id = 'c09_http_503'; http = 503; code = $null; payload = 'not_observed'; quota = 'none'; retryAfter = $false; current = 0; cap = 100; exception = 'none'; expectedCase = 'C-09'; expectedError = 'http_gateway_or_backend_unavailable'; expectedResult = 'unavailable'; expectedRetry = 'bounded_backoff_after_budget_check'; expectedBlocked = $false; expectedTruncated = $false },
        [pscustomobject][ordered]@{ id = 'c09_provider_05'; http = 200; code = '05'; payload = 'provider_error'; quota = 'none'; retryAfter = $false; current = 0; cap = 100; exception = 'none'; expectedCase = 'C-09'; expectedError = 'provider_service_timeout'; expectedResult = 'unavailable'; expectedRetry = 'bounded_backoff_after_budget_check'; expectedBlocked = $false; expectedTruncated = $false },
        [pscustomobject][ordered]@{ id = 'ambiguous_malformed_payload'; http = 200; code = $null; payload = 'malformed'; quota = 'none'; retryAfter = $false; current = 0; cap = 100; exception = 'none'; expectedCase = 'not_classified'; expectedError = 'malformed_payload_origin_unclassified'; expectedResult = 'unavailable'; expectedRetry = 'manual_review'; expectedBlocked = $false; expectedTruncated = $false },
        [pscustomobject][ordered]@{ id = 'ambiguous_empty_payload'; http = 200; code = $null; payload = 'empty_backend_payload'; quota = 'none'; retryAfter = $false; current = 0; cap = 100; exception = 'none'; expectedCase = 'not_classified'; expectedError = 'empty_payload_origin_unclassified'; expectedResult = 'unavailable'; expectedRetry = 'manual_review'; expectedBlocked = $false; expectedTruncated = $false },
        [pscustomobject][ordered]@{ id = 'c10_http_429_retry_after'; http = 429; code = $null; payload = 'not_observed'; quota = 'none'; retryAfter = $true; current = 0; cap = 100; exception = 'none'; expectedCase = 'C-10'; expectedError = 'http_429_rate_limited'; expectedResult = 'unavailable'; expectedRetry = 'retry_after_present_not_parsed'; expectedBlocked = $false; expectedTruncated = $false },
        [pscustomobject][ordered]@{ id = 'c10_http_429_no_retry_after'; http = 429; code = $null; payload = 'not_observed'; quota = 'none'; retryAfter = $false; current = 0; cap = 100; exception = 'none'; expectedCase = 'C-10'; expectedError = 'http_429_rate_limited'; expectedResult = 'unavailable'; expectedRetry = 'manual_budget_review'; expectedBlocked = $false; expectedTruncated = $false },
        [pscustomobject][ordered]@{ id = 'c10_provider_quota_signal'; http = 200; code = $null; payload = 'provider_error'; quota = 'provider_quota_exceeded'; retryAfter = $false; current = 0; cap = 100; exception = 'none'; expectedCase = 'C-10'; expectedError = 'quota_or_rate_limit_exceeded'; expectedResult = 'unavailable'; expectedRetry = 'wait_for_budget_window'; expectedBlocked = $false; expectedTruncated = $false },
        [pscustomobject][ordered]@{ id = 'c10_daily_cap_precheck'; http = $null; code = $null; payload = 'not_observed'; quota = 'none'; retryAfter = $false; current = 100; cap = 100; exception = 'none'; expectedCase = 'C-10'; expectedError = 'daily_cap_precheck_blocked'; expectedResult = 'unavailable'; expectedRetry = 'wait_for_next_budget_day'; expectedBlocked = $true; expectedTruncated = $false },
        [pscustomobject][ordered]@{ id = 'ambiguous_http_403'; http = 403; code = $null; payload = 'not_observed'; quota = 'none'; retryAfter = $false; current = 0; cap = 100; exception = 'none'; expectedCase = 'not_classified'; expectedError = 'http_403_unclassified'; expectedResult = 'not_evaluated'; expectedRetry = 'manual_review'; expectedBlocked = $false; expectedTruncated = $false },
        [pscustomobject][ordered]@{ id = 'ambiguous_truncated_chain'; http = $null; code = $null; payload = 'not_observed'; quota = 'none'; retryAfter = $false; current = 0; cap = 100; exception = 'timeout_beyond_depth_limit'; expectedCase = 'not_classified'; expectedError = 'exception_chain_truncated_unclassified'; expectedResult = 'unavailable'; expectedRetry = 'manual_review'; expectedBlocked = $false; expectedTruncated = $true },
        [pscustomobject][ordered]@{ id = 'conflicting_504_and_quota'; http = 504; code = $null; payload = 'not_observed'; quota = 'provider_quota_exceeded'; retryAfter = $false; current = 0; cap = 100; exception = 'none'; expectedCase = 'not_classified'; expectedError = 'conflicting_c09_c10_signals_unclassified'; expectedResult = 'unavailable'; expectedRetry = 'manual_review'; expectedBlocked = $false; expectedTruncated = $false },
        [pscustomobject][ordered]@{ id = 'outside_success_header'; http = 200; code = '00'; payload = 'valid'; quota = 'none'; retryAfter = $false; current = 0; cap = 100; exception = 'none'; expectedCase = 'not_classified'; expectedError = 'outside_c09_c10_scope'; expectedResult = 'not_evaluated'; expectedRetry = 'manual_review'; expectedBlocked = $false; expectedTruncated = $false }
    )
}

function Get-ExpectedExceptionProjection {
    param([Parameter(Mandatory = $true)][string]$Shape)

    if ($Shape -eq 'timeout_direct') {
        return [pscustomobject][ordered]@{ firstWebExceptionStatus = 'Timeout'; innerDepth = 0; chainTruncated = $false }
    }
    if ($Shape -eq 'timeout_wrapped_depth1') {
        return [pscustomobject][ordered]@{ firstWebExceptionStatus = 'Timeout'; innerDepth = 1; chainTruncated = $false }
    }
    if ($Shape -eq 'timeout_beyond_depth_limit') {
        return [pscustomobject][ordered]@{ firstWebExceptionStatus = $null; innerDepth = 6; chainTruncated = $true }
    }
    return [pscustomobject][ordered]@{ firstWebExceptionStatus = $null; innerDepth = 0; chainTruncated = $false }
}

function Invoke-FixtureMatrix {
    $fixtures = Get-Fixtures
    $rows = @()
    $unhandledCount = 0
    $fixtureSetPass = ($fixtures.Count -eq $ExpectedFixtureIds.Count)
    if ($fixtureSetPass) {
        for ($fixtureIndex = 0; $fixtureIndex -lt $fixtures.Count; $fixtureIndex += 1) {
            if ($fixtures[$fixtureIndex].id -ne $ExpectedFixtureIds[$fixtureIndex]) {
                $fixtureSetPass = $false
                break
            }
        }
    }

    foreach ($fixture in $fixtures) {
        try {
            $syntheticException = New-SyntheticException -Shape $fixture.exception -Marker $SyntheticMarker -UriMarker $SyntheticUri
            $exceptionProjection = Get-SafeExceptionProjection -Exception $syntheticException -MaxDepth $ExceptionMaxDepth
            $expectedExceptionProjection = Get-ExpectedExceptionProjection -Shape $fixture.exception
            $classification = Get-SyntheticOutcomeClassification `
                -HttpStatus $fixture.http `
                -ProviderCode $fixture.code `
                -PayloadStatus $fixture.payload `
                -QuotaSignal $fixture.quota `
                -RetryAfterPresent $fixture.retryAfter `
                -CurrentCalls $fixture.current `
                -DailyCap $fixture.cap `
                -ExceptionProjection $exceptionProjection

            $expectedMatch = (
                $classification.caseId -eq $fixture.expectedCase -and
                $classification.errorClass -eq $fixture.expectedError -and
                $classification.resultKind -eq $fixture.expectedResult -and
                $classification.retryDisposition -eq $fixture.expectedRetry -and
                $classification.requestBlocked -eq $fixture.expectedBlocked -and
                $classification.retryAfterObserved -eq $fixture.retryAfter -and
                -not $classification.sameRunRetryAllowed -and
                -not $classification.retryPolicyExecutionVerified -and
                $exceptionProjection.firstWebExceptionStatus -eq $expectedExceptionProjection.firstWebExceptionStatus -and
                $exceptionProjection.innerDepth -eq $expectedExceptionProjection.innerDepth -and
                $exceptionProjection.chainTruncated -eq $expectedExceptionProjection.chainTruncated -and
                $exceptionProjection.chainTruncated -eq $fixture.expectedTruncated -and
                -not $classification.providerBehaviorVerified
            )

            $rows += [pscustomobject][ordered]@{
                id = $fixture.id
                caseId = $classification.caseId
                errorClass = $classification.errorClass
                resultKind = $classification.resultKind
                retryDisposition = $classification.retryDisposition
                requestBlocked = $classification.requestBlocked
                retryAfterObserved = $classification.retryAfterObserved
                sameRunRetryAllowed = $classification.sameRunRetryAllowed
                retryPolicyExecutionVerified = $classification.retryPolicyExecutionVerified
                firstWebExceptionStatus = $exceptionProjection.firstWebExceptionStatus
                innerDepth = $exceptionProjection.innerDepth
                chainTruncated = $exceptionProjection.chainTruncated
                providerBehaviorVerified = $classification.providerBehaviorVerified
                expectedMatch = $expectedMatch
            }
        }
        catch {
            $unhandledCount += 1
            $rows += [pscustomobject][ordered]@{
                id = $fixture.id
                caseId = 'not_classified'
                errorClass = 'fixture_unhandled'
                resultKind = 'not_evaluated'
                retryDisposition = 'manual_review'
                requestBlocked = $false
                retryAfterObserved = $false
                sameRunRetryAllowed = $false
                retryPolicyExecutionVerified = $false
                firstWebExceptionStatus = $null
                innerDepth = 0
                chainTruncated = $false
                providerBehaviorVerified = $false
                expectedMatch = $false
            }
        }
        finally {
            $syntheticException = $null
            $exceptionProjection = $null
            $expectedExceptionProjection = $null
            $classification = $null
        }
    }

    $descriptorRows = @()
    foreach ($fixture in $fixtures) {
        $expectedExceptionProjection = Get-ExpectedExceptionProjection -Shape $fixture.exception
        $descriptorRows += [pscustomobject][ordered]@{
            id = $fixture.id
            providerProfile = $ProviderProfile
            fixedClock = $FixedClock
            syntheticMarker = $SyntheticMarker
            syntheticUri = $SyntheticUri
            exceptionMaxDepth = $ExceptionMaxDepth
            httpStatus = $fixture.http
            providerCode = $fixture.code
            payloadStatus = $fixture.payload
            quotaSignal = $fixture.quota
            retryAfterPresent = $fixture.retryAfter
            currentCalls = $fixture.current
            dailyCap = $fixture.cap
            exceptionShape = $fixture.exception
            expectedCase = $fixture.expectedCase
            expectedError = $fixture.expectedError
            expectedResult = $fixture.expectedResult
            expectedRetry = $fixture.expectedRetry
            expectedBlocked = $fixture.expectedBlocked
            expectedRetryAfterObserved = $fixture.retryAfter
            expectedSameRunRetryAllowed = $false
            expectedRetryPolicyExecutionVerified = $false
            expectedFirstWebExceptionStatus = $expectedExceptionProjection.firstWebExceptionStatus
            expectedInnerDepth = $expectedExceptionProjection.innerDepth
            expectedTruncated = $expectedExceptionProjection.chainTruncated
            expectedProviderBehaviorVerified = $false
        }
        $expectedExceptionProjection = $null
    }

    $descriptorJson = $descriptorRows | ConvertTo-Json -Depth 5 -Compress
    $projectionJson = $rows | ConvertTo-Json -Depth 5 -Compress
    $allExpected = (
        $fixtureSetPass -and
        @($rows | Where-Object { -not $_.expectedMatch }).Count -eq 0
    )
    $redactionPass = (
        -not $projectionJson.Contains($SyntheticMarker) -and
        -not $projectionJson.Contains($SyntheticUri) -and
        -not $projectionJson.Contains('serviceKey=')
    )

    return [pscustomobject][ordered]@{
        fixtureCount = $fixtures.Count
        fixtureSetPass = $fixtureSetPass
        descriptorSha256 = Get-TextSha256 -Text $descriptorJson
        projectionSha256 = Get-TextSha256 -Text $projectionJson
        allExpected = $allExpected
        unhandledCount = $unhandledCount
        redactionPass = $redactionPass
        rows = $rows
    }
}

try {
    $first = Invoke-FixtureMatrix
    $second = Invoke-FixtureMatrix
    $deterministic = (
        $first.descriptorSha256 -eq $second.descriptorSha256 -and
        $first.projectionSha256 -eq $second.projectionSha256
    )
    $fixtureHashLockPass = (
        $first.descriptorSha256 -eq $ExpectedDescriptorSha256 -and
        $first.projectionSha256 -eq $ExpectedProjectionSha256
    )

    $result = [ordered]@{
        mode = 'offline_error_contract_self_test'
        classifierId = $ClassifierId
        sourceClass = $FixtureSourceClass
        providerProfile = $ProviderProfile
        fixedClock = $FixedClock
        scriptSha256 = Get-FileSha256 -Path $PSCommandPath
        fixtureCount = $first.fixtureCount
        fixtureSetPass = ($first.fixtureSetPass -and $second.fixtureSetPass)
        caseCoverage = @('C-09', 'C-10', 'ambiguous_fail_closed')
        descriptorSha256 = $first.descriptorSha256
        resultProjectionSha256 = $first.projectionSha256
        fixtureHashLockPass = $fixtureHashLockPass
        allExpected = $first.allExpected
        deterministic = $deterministic
        unhandledCount = $first.unhandledCount + $second.unhandledCount
        redactionPass = ($first.redactionPass -and $second.redactionPass)
        networkCalls = 0
        retryExecuted = 0
        sameRunRetryAllowed = $false
        retryPolicyExecutionVerified = $false
        sleepExecuted = 0
        redirects = 0
        providerBehaviorVerified = $false
        pass = (
            $first.allExpected -and
            $second.allExpected -and
            $first.fixtureSetPass -and
            $second.fixtureSetPass -and
            $fixtureHashLockPass -and
            $deterministic -and
            $first.unhandledCount -eq 0 -and
            $second.unhandledCount -eq 0 -and
            $first.redactionPass -and
            $second.redactionPass
        )
    }

    if ($IncludeFixtureResults) {
        $result.fixtureResults = $first.rows
    }

    $json = $result | ConvertTo-Json -Depth 8 -Compress
    if ($json.Contains($SyntheticMarker) -or $json.Contains($SyntheticUri) -or $json.Contains('serviceKey=')) {
        throw New-Object InvalidOperationException('Sanitized output rejected')
    }

    $json
    if (-not $result.pass) {
        exit 1
    }
}
catch {
    $failure = [ordered]@{
        mode = 'offline_error_contract_self_test'
        classifierId = $ClassifierId
        sourceClass = $FixtureSourceClass
        errorClass = $_.Exception.GetType().FullName
        networkCalls = 0
        retryExecuted = 0
        providerBehaviorVerified = $false
        pass = $false
    }
    $failure | ConvertTo-Json -Depth 4 -Compress
    exit 1
}
