param(
    [switch]$OfflineSelfTest,
    [switch]$Execute,
    [string]$ExpectedPlanHash
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'
$DebugPreference = 'SilentlyContinue'
$InformationPreference = 'SilentlyContinue'
Set-StrictMode -Version Latest

$PlanId = 'contract-smoke-20260810-v9'
$RunId = 'contract-smoke-20260810-r9'
$ParentRunId = 'contract-smoke-20260810-r8'
$ValidatorId = 'air-measurement-validator-v2-offline'
$ParentFixtureDescriptorHash = 'fb77f81a621fe77f6bd5672f4366e060781bc6e1fbac869b9c9a870621b4fd13'
$ParentFixtureResultHash = '71c0037a02245ecc7cd006eddb01cdefeecd0b042be3a35968efe0ae6e803a09'
$EndpointPath = '/getMsrstnAcctoRltmMesureDnsty'
$ServicePath = '/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty'
$EndpointUri = 'https://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty'
$StationName = [string]([char]0xC885) + [string]([char]0xB85C) + [string]([char]0xAD6C)
$ResponseLimitBytes = 2097152
$PreCallCount = 9

function Get-TextSha256([string]$Text) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        return [BitConverter]::ToString(
            $sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($Text))
        ).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

function Get-FileSha256([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-PropertyRecord($Object, [string]$Name) {
    if ($null -eq $Object) {
        return [pscustomobject]@{ exists = $false; value = $null }
    }

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return [pscustomobject]@{ exists = $false; value = $null }
    }

    return [pscustomobject]@{ exists = $true; value = $property.Value }
}

function Test-AvailableValue($Value) {
    return (
        $null -ne $Value -and
        -not [string]::IsNullOrWhiteSpace([string]$Value) -and
        [string]$Value -ne '-'
    )
}

function Get-OccurrenceCount([string]$Text, [string]$Needle) {
    if ([string]::IsNullOrEmpty($Text) -or [string]::IsNullOrEmpty($Needle)) {
        return 0
    }

    $count = 0
    $offset = 0
    while (($index = $Text.IndexOf($Needle, $offset, [StringComparison]::Ordinal)) -ge 0) {
        $count++
        $offset = $index + $Needle.Length
    }
    return $count
}

function Get-ByteOccurrenceCount([byte[]]$Bytes, [byte[]]$Needle) {
    if ($null -eq $Bytes -or $null -eq $Needle -or $Needle.Length -eq 0 -or
        $Bytes.Length -lt $Needle.Length) {
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

function Get-C12Counts([string]$Raw, [string]$Encoded, [string]$RepoRoot) {
    $rawRepo = 0
    $encodedRepo = 0
    $rawEnv = 0
    $encodedEnv = 0
    $scanErrors = 0
    $fileCount = 0
    $gitPrefix = [IO.Path]::GetFullPath((Join-Path $RepoRoot '.git')) + [IO.Path]::DirectorySeparatorChar
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
    if ($encodedLowerEscapes -cne $Encoded) {
        $encodedValues += $encodedLowerEscapes
    }
    $encodedNeedles = @()
    foreach ($encodedValue in $encodedValues) {
        $encodedNeedles += ,([Text.Encoding]::UTF8.GetBytes($encodedValue))
        $encodedNeedles += ,([Text.Encoding]::Unicode.GetBytes($encodedValue))
        $encodedNeedles += ,([Text.Encoding]::BigEndianUnicode.GetBytes($encodedValue))
    }

    $enumerationErrors = @()
    $files = @(Get-ChildItem -LiteralPath $RepoRoot -Recurse -Force -File `
        -ErrorAction SilentlyContinue -ErrorVariable +enumerationErrors)
    $scanErrors += @($enumerationErrors).Count
    foreach ($file in $files) {
        $full = [IO.Path]::GetFullPath($file.FullName)
        if ($full.StartsWith($gitPrefix, [StringComparison]::OrdinalIgnoreCase)) {
            continue
        }

        $fileCount++
        try {
            $contentBytes = [IO.File]::ReadAllBytes($full)
        }
        catch {
            $scanErrors++
            continue
        }

        foreach ($needle in $rawNeedles) {
            $rawRepo += Get-ByteOccurrenceCount $contentBytes $needle
        }
        foreach ($needle in $encodedNeedles) {
            $encodedRepo += Get-ByteOccurrenceCount $contentBytes $needle
        }
        $contentBytes = $null
    }

    foreach ($entry in Get-ChildItem Env:) {
        $value = [string]$entry.Value
        $rawEnv += Get-OccurrenceCount $value $Raw
        foreach ($encodedValue in $encodedValues) {
            $encodedEnv += Get-OccurrenceCount $value $encodedValue
        }
        $value = $null
    }

    return [pscustomobject]@{
        rawRepo = $rawRepo
        encodedRepo = $encodedRepo
        rawEnv = $rawEnv
        encodedEnv = $encodedEnv
        scanErrors = $scanErrors
        fileCount = $fileCount
    }
}

function Read-LimitedUtf8([IO.Stream]$Stream, [int]$Limit) {
    $memory = New-Object IO.MemoryStream
    try {
        $buffer = New-Object byte[] 8192
        while (($read = $Stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            if (($memory.Length + $read) -gt $Limit) {
                throw [IO.InvalidDataException]::new('response_limit_exceeded')
            }
            $memory.Write($buffer, 0, $read)
        }
        return [Text.Encoding]::UTF8.GetString($memory.ToArray())
    }
    finally {
        $memory.Dispose()
    }
}

function ConvertTo-SafeValidationResult(
    [string]$Json,
    [switch]$FixtureMode,
    [DateTimeOffset]$EvaluationNow = [DateTimeOffset]::MinValue
) {
    $stage = 'json'
    $observedProviderCode = $null
    $observedProviderHeaderStatus = 'not_observed'
    $observedJsonHeaderParse = 'not_observed'
    $observedDataBodyStatus = 'not_observed'
    try {
        $document = ConvertFrom-Json -InputObject $Json
        $stage = 'response'

        $responseRecord = Get-PropertyRecord $document 'response'
        if (-not $responseRecord.exists) {
            return [pscustomobject]@{
                providerCode = $null; providerHeaderStatus = 'not_observed'
                jsonHeaderParse = 'fail'; dataBodyStatus = 'not_observed'
                schemaStatus = 'not_observed'; c01 = 'fail'
                resultKind = 'unavailable'; errorClass = 'response_envelope_missing'
                itemCount = $null; missingFields = @(); fieldSignature = @()
                nullFields = @(); missingValueFields = @(); stationMatch = $false
                dataTimeParseable = $false; observationAgeMinutes = $null
                freshnessStatus = 'not_evaluable'; qualityStatus = 'not_evaluable'
            }
        }

        $headerRecord = Get-PropertyRecord $responseRecord.value 'header'
        if (-not $headerRecord.exists) {
            return [pscustomobject]@{
                providerCode = $null; providerHeaderStatus = 'not_observed'
                jsonHeaderParse = 'fail'; dataBodyStatus = 'not_observed'
                schemaStatus = 'not_observed'; c01 = 'fail'
                resultKind = 'unavailable'; errorClass = 'provider_header_missing'
                itemCount = $null; missingFields = @(); fieldSignature = @()
                nullFields = @(); missingValueFields = @(); stationMatch = $false
                dataTimeParseable = $false; observationAgeMinutes = $null
                freshnessStatus = 'not_evaluable'; qualityStatus = 'not_evaluable'
            }
        }

        $codeRecord = Get-PropertyRecord $headerRecord.value 'resultCode'
        if (-not $codeRecord.exists) {
            return [pscustomobject]@{
                providerCode = $null; providerHeaderStatus = 'code_missing'
                jsonHeaderParse = 'pass'; dataBodyStatus = 'not_observed'
                schemaStatus = 'not_observed'; c01 = 'fail'
                resultKind = 'unavailable'; errorClass = 'provider_code_missing'
                itemCount = $null; missingFields = @(); fieldSignature = @()
                nullFields = @(); missingValueFields = @(); stationMatch = $false
                dataTimeParseable = $false; observationAgeMinutes = $null
                freshnessStatus = 'not_evaluable'; qualityStatus = 'not_evaluable'
            }
        }

        $providerCode = [string]$codeRecord.value
        if ($providerCode -notmatch '^[0-9]{2}$') {
            return [pscustomobject]@{
                providerCode = $null; providerHeaderStatus = 'unsafe_code_rejected'
                jsonHeaderParse = 'pass'; dataBodyStatus = 'not_evaluated'
                schemaStatus = 'not_evaluated'; c01 = 'fail'
                resultKind = 'unavailable'; errorClass = 'provider_code_unsafe'
                itemCount = $null; missingFields = @(); fieldSignature = @()
                nullFields = @(); missingValueFields = @(); stationMatch = $false
                dataTimeParseable = $false; observationAgeMinutes = $null
                freshnessStatus = 'not_evaluable'; qualityStatus = 'not_evaluable'
            }
        }
        if ($providerCode -ne '00') {
            return [pscustomobject]@{
                providerCode = $providerCode; providerHeaderStatus = 'provider_error'
                jsonHeaderParse = 'pass'; dataBodyStatus = 'not_evaluated'
                schemaStatus = 'not_evaluated'; c01 = 'fail'
                resultKind = 'unavailable'; errorClass = 'provider_error'
                itemCount = $null; missingFields = @(); fieldSignature = @()
                nullFields = @(); missingValueFields = @(); stationMatch = $false
                dataTimeParseable = $false; observationAgeMinutes = $null
                freshnessStatus = 'not_evaluable'; qualityStatus = 'not_evaluable'
            }
        }
        $observedProviderCode = $providerCode
        $observedProviderHeaderStatus = 'observed_success'
        $observedJsonHeaderParse = 'pass'

        $stage = 'body'
        $bodyRecord = Get-PropertyRecord $responseRecord.value 'body'
        if (-not $bodyRecord.exists) {
            return [pscustomobject]@{
                providerCode = $providerCode; providerHeaderStatus = 'observed_success'
                jsonHeaderParse = 'pass'; dataBodyStatus = 'missing'
                schemaStatus = 'not_observed'; c01 = 'fail'
                resultKind = 'unavailable'; errorClass = 'body_missing'
                itemCount = $null; missingFields = @(); fieldSignature = @()
                nullFields = @(); missingValueFields = @(); stationMatch = $false
                dataTimeParseable = $false; observationAgeMinutes = $null
                freshnessStatus = 'not_evaluable'; qualityStatus = 'not_evaluable'
            }
        }

        $itemsRecord = Get-PropertyRecord $bodyRecord.value 'items'
        $observedDataBodyStatus = 'observed'
        if (-not $itemsRecord.exists) {
            return [pscustomobject]@{
                providerCode = $providerCode; providerHeaderStatus = 'observed_success'
                jsonHeaderParse = 'pass'; dataBodyStatus = 'observed'
                schemaStatus = 'items_container_missing'; c01 = 'fail'
                resultKind = 'unavailable'; errorClass = 'items_container_missing'
                itemCount = $null; missingFields = @(); fieldSignature = @()
                nullFields = @(); missingValueFields = @(); stationMatch = $false
                dataTimeParseable = $false; observationAgeMinutes = $null
                freshnessStatus = 'not_evaluable'; qualityStatus = 'not_evaluable'
            }
        }

        $node = $itemsRecord.value
        if ($null -eq $node) {
            return [pscustomobject]@{
                providerCode = $providerCode; providerHeaderStatus = 'observed_success'
                jsonHeaderParse = 'pass'; dataBodyStatus = 'observed'
                schemaStatus = 'items_null'; c01 = 'fail'
                resultKind = 'unavailable'; errorClass = 'items_null'
                itemCount = 0; missingFields = @(); fieldSignature = @()
                nullFields = @(); missingValueFields = @(); stationMatch = $false
                dataTimeParseable = $false; observationAgeMinutes = $null
                freshnessStatus = 'not_evaluable'; qualityStatus = 'not_evaluable'
            }
        }

        $wrappedRecord = Get-PropertyRecord $node 'item'
        if ($wrappedRecord.exists) {
            $node = $wrappedRecord.value
        }
        if ($null -eq $node) {
            return [pscustomobject]@{
                providerCode = $providerCode; providerHeaderStatus = 'observed_success'
                jsonHeaderParse = 'pass'; dataBodyStatus = 'observed'
                schemaStatus = 'items_null'; c01 = 'fail'
                resultKind = 'unavailable'; errorClass = 'items_null'
                itemCount = 0; missingFields = @(); fieldSignature = @()
                nullFields = @(); missingValueFields = @(); stationMatch = $false
                dataTimeParseable = $false; observationAgeMinutes = $null
                freshnessStatus = 'not_evaluable'; qualityStatus = 'not_evaluable'
            }
        }

        $items = @($node)
        if ($items.Count -eq 0) {
            return [pscustomobject]@{
                providerCode = $providerCode; providerHeaderStatus = 'observed_success'
                jsonHeaderParse = 'pass'; dataBodyStatus = 'observed'
                schemaStatus = 'items_empty'; c01 = 'fail'
                resultKind = 'unavailable'; errorClass = 'items_empty'
                itemCount = 0; missingFields = @(); fieldSignature = @()
                nullFields = @(); missingValueFields = @(); stationMatch = $false
                dataTimeParseable = $false; observationAgeMinutes = $null
                freshnessStatus = 'not_evaluable'; qualityStatus = 'not_evaluable'
            }
        }

        $stage = 'schema'
        $requiredFields = @('stationName', 'dataTime', 'pm10Value', 'pm25Value')
        $missingFields = @()
        foreach ($field in $requiredFields) {
            $fieldRecord = Get-PropertyRecord $items[0] $field
            if (-not $fieldRecord.exists) {
                $missingFields += $field
            }
        }
        $missingFields = @($missingFields)

        $properties = @($items[0].PSObject.Properties | Sort-Object Name)
        $propertyNamesSafe = ($properties.Count -le 128)
        foreach ($property in $properties) {
            if ([string]$property.Name -notmatch '^[A-Za-z][A-Za-z0-9_]{0,63}$') {
                $propertyNamesSafe = $false
                break
            }
        }
        if (-not $propertyNamesSafe) {
            return [pscustomobject]@{
                providerCode = $providerCode; providerHeaderStatus = 'observed_success'
                jsonHeaderParse = 'pass'; dataBodyStatus = 'observed'
                schemaStatus = 'unsafe_field_signature'; c01 = 'fail'
                resultKind = 'unavailable'; errorClass = 'schema_field_name_or_count_rejected'
                itemCount = $items.Count; missingFields = @(); fieldSignature = @()
                nullFields = @(); missingValueFields = @(); stationMatch = $false
                dataTimeParseable = $false; observationAgeMinutes = $null
                freshnessStatus = 'not_evaluable'; qualityStatus = 'not_evaluable'
            }
        }

        $fieldSignature = @()
        $nullFields = @()
        $missingValueFields = @()
        foreach ($field in $requiredFields) {
            $requiredRecord = Get-PropertyRecord $items[0] $field
            if (-not $requiredRecord.exists) {
                continue
            }
            $typeName = if ($null -eq $requiredRecord.value) {
                'null'
            }
            elseif ($requiredRecord.value -is [string]) {
                'String'
            }
            elseif ($requiredRecord.value -is [bool]) {
                'Boolean'
            }
            elseif ($requiredRecord.value -is [ValueType]) {
                'Number'
            }
            else {
                'Other'
            }
            $fieldSignature += ('{0}:{1}' -f $field, $typeName)
            if ($null -eq $requiredRecord.value) {
                $nullFields += $field
            }
            elseif (-not (Test-AvailableValue $requiredRecord.value)) {
                $missingValueFields += $field
            }
        }

        if ($missingFields.Count -gt 0) {
            return [pscustomobject]@{
                providerCode = $providerCode; providerHeaderStatus = 'observed_success'
                jsonHeaderParse = 'pass'; dataBodyStatus = 'observed'
                schemaStatus = 'required_fields_missing'; c01 = 'fail'
                resultKind = 'partial'; errorClass = 'required_schema_missing'
                itemCount = $items.Count; missingFields = $missingFields
                fieldSignature = $fieldSignature; nullFields = $nullFields
                missingValueFields = $missingValueFields; stationMatch = $false
                dataTimeParseable = $false; observationAgeMinutes = $null
                freshnessStatus = 'not_evaluable'; qualityStatus = 'not_evaluable'
            }
        }

        $stationValue = (Get-PropertyRecord $items[0] 'stationName').value
        $dataTimeValue = [string](Get-PropertyRecord $items[0] 'dataTime').value
        $pm10Value = (Get-PropertyRecord $items[0] 'pm10Value').value
        $pm25Value = (Get-PropertyRecord $items[0] 'pm25Value').value
        $stationMatch = ([string]$stationValue -eq $StationName)
        $pm10Available = Test-AvailableValue $pm10Value
        $pm25Available = Test-AvailableValue $pm25Value
        $dataTimeParseable = $false
        $observationAgeMinutes = $null
        $freshnessStatus = 'not_evaluable'

        if ($FixtureMode) {
            $qualityStatus = if ($pm10Available -and $pm25Available) { 'usable_fixture' } else { 'partial_fixture' }
        }
        else {
            $parsed = [DateTime]::MinValue
            $dataTimeParseable = [DateTime]::TryParseExact(
                $dataTimeValue,
                'yyyy-MM-dd HH:mm',
                [Globalization.CultureInfo]::InvariantCulture,
                [Globalization.DateTimeStyles]::None,
                [ref]$parsed
            )
            if (-not $dataTimeParseable) {
                $dataTimeParseable = [DateTime]::TryParse(
                    $dataTimeValue,
                    [Globalization.CultureInfo]::InvariantCulture,
                    [Globalization.DateTimeStyles]::None,
                    [ref]$parsed
                )
            }

            if ($dataTimeParseable) {
                $observedAt = [DateTimeOffset]::new(
                    [DateTime]::SpecifyKind($parsed, [DateTimeKind]::Unspecified),
                    [TimeSpan]::FromHours(9)
                )
                $evaluationClock = if ($EvaluationNow -eq [DateTimeOffset]::MinValue) {
                    [DateTimeOffset]::Now
                }
                else {
                    $EvaluationNow
                }
                $observationAgeMinutes = [int][Math]::Round(($evaluationClock - $observedAt).TotalMinutes)
                if ($observationAgeMinutes -lt -10) {
                    $freshnessStatus = 'future'
                }
                elseif ($observationAgeMinutes -le 120) {
                    $freshnessStatus = 'fresh'
                }
                elseif ($observationAgeMinutes -le 240) {
                    $freshnessStatus = 'delayed'
                }
                else {
                    $freshnessStatus = 'stale'
                }
            }
            else {
                $freshnessStatus = 'unparseable'
            }

            if (-not $stationMatch) {
                $qualityStatus = 'unusable'
            }
            elseif (-not $dataTimeParseable -or $freshnessStatus -eq 'future') {
                $qualityStatus = 'not_fresh'
            }
            elseif (-not $pm10Available -or -not $pm25Available) {
                $qualityStatus = 'partial'
            }
            else {
                $qualityStatus = $freshnessStatus
            }
        }

        return [pscustomobject]@{
            providerCode = $providerCode; providerHeaderStatus = 'observed_success'
            jsonHeaderParse = 'pass'; dataBodyStatus = 'observed'
            schemaStatus = 'required_fields_observed'; c01 = 'pass'
            resultKind = if ($pm10Available -and $pm25Available) { 'data' } else { 'partial' }
            errorClass = $null; itemCount = $items.Count
            missingFields = @(); fieldSignature = $fieldSignature
            nullFields = $nullFields; missingValueFields = $missingValueFields
            stationMatch = $stationMatch; dataTimeParseable = $dataTimeParseable
            observationAgeMinutes = $observationAgeMinutes
            freshnessStatus = $freshnessStatus; qualityStatus = $qualityStatus
        }
    }
    catch {
        return [pscustomobject]@{
            providerCode = $observedProviderCode
            providerHeaderStatus = $observedProviderHeaderStatus
            jsonHeaderParse = if ($stage -eq 'json') { 'fail' } else { $observedJsonHeaderParse }
            dataBodyStatus = $observedDataBodyStatus; schemaStatus = 'not_observed'
            c01 = 'fail'; resultKind = 'unavailable'
            errorClass = if ($stage -eq 'json') { 'response_parse_error' } else { 'validator_unhandled' }
            itemCount = $null; missingFields = @(); fieldSignature = @()
            nullFields = @(); missingValueFields = @(); stationMatch = $false
            dataTimeParseable = $false; observationAgeMinutes = $null
            freshnessStatus = 'not_evaluable'; qualityStatus = 'not_evaluable'
        }
    }
}

function Invoke-OfflineValidatorMatrix {
    $cases = [ordered]@{}
    $cases['normal_single'] = '{"response":{"header":{"resultCode":"00"},"body":{"items":[{"stationName":"SYN","dataTime":"2026-08-10 07:00","pm10Value":"SYN","pm25Value":"SYN"}]}}}'
    $cases['normal_wrapper'] = '{"response":{"header":{"resultCode":"00"},"body":{"items":{"item":[{"stationName":"SYN","dataTime":"2026-08-10 07:00","pm10Value":"SYN","pm25Value":"SYN"}]}}}}'
    $cases['normal_multiple'] = '{"response":{"header":{"resultCode":"00"},"body":{"items":[{"stationName":"SYN","dataTime":"2026-08-10 07:00","pm10Value":"SYN","pm25Value":"SYN"},{"stationName":"SYN","dataTime":"2026-08-10 06:00","pm10Value":"SYN","pm25Value":"SYN"}]}}}'
    $cases['items_empty'] = '{"response":{"header":{"resultCode":"00"},"body":{"items":[]}}}'
    $cases['items_null'] = '{"response":{"header":{"resultCode":"00"},"body":{"items":null}}}'
    $cases['items_missing'] = '{"response":{"header":{"resultCode":"00"},"body":{}}}'
    $cases['body_missing'] = '{"response":{"header":{"resultCode":"00"}}}'
    $cases['missing_stationName'] = '{"response":{"header":{"resultCode":"00"},"body":{"items":[{"dataTime":"2026-08-10 07:00","pm10Value":"SYN","pm25Value":"SYN"}]}}}'
    $cases['missing_dataTime'] = '{"response":{"header":{"resultCode":"00"},"body":{"items":[{"stationName":"SYN","pm10Value":"SYN","pm25Value":"SYN"}]}}}'
    $cases['missing_pm10Value'] = '{"response":{"header":{"resultCode":"00"},"body":{"items":[{"stationName":"SYN","dataTime":"2026-08-10 07:00","pm25Value":"SYN"}]}}}'
    $cases['missing_pm25Value'] = '{"response":{"header":{"resultCode":"00"},"body":{"items":[{"stationName":"SYN","dataTime":"2026-08-10 07:00","pm10Value":"SYN"}]}}}'
    $cases['pm_null'] = '{"response":{"header":{"resultCode":"00"},"body":{"items":[{"stationName":"SYN","dataTime":"2026-08-10 07:00","pm10Value":null,"pm25Value":null}]}}}'
    $cases['pm_dash'] = '{"response":{"header":{"resultCode":"00"},"body":{"items":[{"stationName":"SYN","dataTime":"2026-08-10 07:00","pm10Value":"-","pm25Value":"-"}]}}}'
    $cases['provider_error'] = '{"response":{"header":{"resultCode":"05"},"body":{}}}'
    $cases['malformed'] = '{"response":'
    $cases['response_missing'] = '{}'
    $cases['header_missing'] = '{"response":{}}'
    $cases['provider_code_missing'] = '{"response":{"header":{},"body":{}}}'

    $expected = [ordered]@{
        normal_single = 'pass|data|'
        normal_wrapper = 'pass|data|'
        normal_multiple = 'pass|data|'
        items_empty = 'fail|unavailable|items_empty'
        items_null = 'fail|unavailable|items_null'
        items_missing = 'fail|unavailable|items_container_missing'
        body_missing = 'fail|unavailable|body_missing'
        missing_stationName = 'fail|partial|required_schema_missing'
        missing_dataTime = 'fail|partial|required_schema_missing'
        missing_pm10Value = 'fail|partial|required_schema_missing'
        missing_pm25Value = 'fail|partial|required_schema_missing'
        pm_null = 'pass|partial|'
        pm_dash = 'pass|partial|'
        provider_error = 'fail|unavailable|provider_error'
        malformed = 'fail|unavailable|response_parse_error'
        response_missing = 'fail|unavailable|response_envelope_missing'
        header_missing = 'fail|unavailable|provider_header_missing'
        provider_code_missing = 'fail|unavailable|provider_code_missing'
    }

    $rows = @()
    foreach ($entry in $cases.GetEnumerator()) {
        $validation = ConvertTo-SafeValidationResult $entry.Value -FixtureMode
        $actual = '{0}|{1}|{2}' -f $validation.c01, $validation.resultKind, [string]$validation.errorClass
        $rows += [pscustomobject]@{
            case = $entry.Key
            c01 = $validation.c01
            resultKind = $validation.resultKind
            errorClass = $validation.errorClass
            itemCount = $validation.itemCount
            missingFields = @($validation.missingFields)
            qualityStatus = $validation.qualityStatus
            expectedMatch = ($actual -eq $expected[$entry.Key])
        }
    }

    $qualityNow = [DateTimeOffset]::Parse('2026-08-10T08:00:00+09:00')
    $qualityCases = [ordered]@{}
    $qualityCases['quality_fresh'] = '{"response":{"header":{"resultCode":"00"},"body":{"items":[{"stationName":"TARGET","dataTime":"2026-08-10 07:00","pm10Value":"SYN","pm25Value":"SYN"}]}}}'.Replace('TARGET', $StationName)
    $qualityCases['quality_delayed'] = '{"response":{"header":{"resultCode":"00"},"body":{"items":[{"stationName":"TARGET","dataTime":"2026-08-10 05:00","pm10Value":"SYN","pm25Value":"SYN"}]}}}'.Replace('TARGET', $StationName)
    $qualityCases['quality_stale'] = '{"response":{"header":{"resultCode":"00"},"body":{"items":[{"stationName":"TARGET","dataTime":"2026-08-10 03:00","pm10Value":"SYN","pm25Value":"SYN"}]}}}'.Replace('TARGET', $StationName)
    $qualityCases['quality_future'] = '{"response":{"header":{"resultCode":"00"},"body":{"items":[{"stationName":"TARGET","dataTime":"2026-08-10 09:00","pm10Value":"SYN","pm25Value":"SYN"}]}}}'.Replace('TARGET', $StationName)
    $qualityCases['quality_unparseable'] = '{"response":{"header":{"resultCode":"00"},"body":{"items":[{"stationName":"TARGET","dataTime":"INVALID","pm10Value":"SYN","pm25Value":"SYN"}]}}}'.Replace('TARGET', $StationName)
    $qualityCases['quality_station_mismatch'] = '{"response":{"header":{"resultCode":"00"},"body":{"items":[{"stationName":"SYN","dataTime":"2026-08-10 07:00","pm10Value":"SYN","pm25Value":"SYN"}]}}}'
    $qualityCases['quality_partial'] = '{"response":{"header":{"resultCode":"00"},"body":{"items":[{"stationName":"TARGET","dataTime":"2026-08-10 07:00","pm10Value":"-","pm25Value":"SYN"}]}}}'.Replace('TARGET', $StationName)
    $qualityExpected = [ordered]@{
        quality_fresh = 'pass|data||fresh|fresh|True|True'
        quality_delayed = 'pass|data||delayed|delayed|True|True'
        quality_stale = 'pass|data||stale|stale|True|True'
        quality_future = 'pass|data||future|not_fresh|True|True'
        quality_unparseable = 'pass|data||unparseable|not_fresh|True|False'
        quality_station_mismatch = 'pass|data||fresh|unusable|False|True'
        quality_partial = 'pass|partial||fresh|partial|True|True'
    }
    foreach ($entry in $qualityCases.GetEnumerator()) {
        $validation = ConvertTo-SafeValidationResult $entry.Value -EvaluationNow $qualityNow
        $actual = '{0}|{1}|{2}|{3}|{4}|{5}|{6}' -f
            $validation.c01, $validation.resultKind, [string]$validation.errorClass,
            $validation.freshnessStatus, $validation.qualityStatus,
            [string]$validation.stationMatch, [string]$validation.dataTimeParseable
        $rows += [pscustomobject]@{
            case = $entry.Key
            c01 = $validation.c01
            resultKind = $validation.resultKind
            errorClass = $validation.errorClass
            itemCount = $validation.itemCount
            missingFields = @($validation.missingFields)
            qualityStatus = $validation.qualityStatus
            expectedMatch = ($actual -eq $qualityExpected[$entry.Key])
        }
    }

    $projection = $rows | ConvertTo-Json -Compress -Depth 5
    $descriptor = [string]::Join('|', @(
        @($expected.GetEnumerator() | ForEach-Object { $_.Key + '=' + $_.Value }) +
        @($qualityExpected.GetEnumerator() | ForEach-Object { $_.Key + '=' + $_.Value })
    ))

    return [pscustomobject]@{
        validatorId = $ValidatorId
        fixtureCount = $cases.Count + $qualityCases.Count
        fixtureDescriptorSha256 = Get-TextSha256 $descriptor
        resultProjectionSha256 = Get-TextSha256 $projection
        allExpected = (@($rows | Where-Object { -not $_.expectedMatch }).Count -eq 0)
        unhandledCount = @($rows | Where-Object { $_.errorClass -eq 'validator_unhandled' }).Count
    }
}

function Get-SanitizedExceptionRecord($Exception) {
    $node = $Exception
    $root = $Exception
    $firstWeb = $null
    $innerDepth = 0
    $chainTruncated = $false

    while ($null -ne $node) {
        $root = $node
        if ($null -eq $firstWeb -and $node -is [Net.WebException]) {
            $firstWeb = $node
        }
        if ($null -eq $node.InnerException) {
            break
        }
        if ($innerDepth -ge 5) {
            $chainTruncated = $true
            break
        }
        $node = $node.InnerException
        $innerDepth++
    }

    $safeHttpStatus = $null
    $webResponseDisposeSucceeded = $true
    $webResponse = if ($null -eq $firstWeb) { $null } else { $firstWeb.Response }
    if ($webResponse -is [Net.HttpWebResponse]) {
        $safeHttpStatus = [int]([Net.HttpWebResponse]$webResponse).StatusCode
    }
    if ($null -ne $webResponse) {
        try {
            $webResponse.Dispose()
        }
        catch {
            $webResponseDisposeSucceeded = $false
        }
    }
    $webResponse = $null
    $firstWeb = $null
    $node = $null
    $rootTypeName = $root.GetType().FullName
    $root = $null

    return [pscustomobject]@{
        outerClass = $Exception.GetType().FullName
        rootClass = $rootTypeName
        innerDepth = $innerDepth
        chainTruncated = $chainTruncated
        webExceptionStatus = if ($Exception -is [Net.WebException]) {
            [string]$Exception.Status
        }
        else {
            $cursor = $Exception
            $status = $null
            for ($depth = 0; $depth -le 5 -and $null -ne $cursor; $depth++) {
                if ($cursor -is [Net.WebException]) {
                    $status = [string]$cursor.Status
                    break
                }
                $cursor = $cursor.InnerException
            }
            $cursor = $null
            $status
        }
        httpStatus = $safeHttpStatus
        webResponseDisposeSucceeded = $webResponseDisposeSucceeded
    }
}

function Test-SafeOutputRecord($Record) {
    $allowedNames = @(
        'planId','runId','parentRunId','evaluatedAt','phase','networkCalls','endpointPath',
        'httpStatus','providerCode','providerHeaderStatus','jsonHeaderParse','dataBodyStatus',
        'schemaStatus','itemCount','missingRequiredFields','fieldSignature','nullFields',
        'missingValueFields','stationMatch','dataTimeParseable','observationAgeMinutes',
        'freshnessStatus','qualityStatus','responseBytes','sanitizedProjectionSha256',
        'localValidator','providerContractVerdict','resultKind','errorClass','outerErrorClass',
        'rootErrorClass','innerDepth','chainTruncated','webExceptionStatus','c01','c09','c10',
        'retry','redirect','rawResponseStored','fullUrlStored','planSha256','scriptSha256',
        'scriptHashBeforeMatch','scriptHashAfterMatch','durationMs','preflightPlanHashMatch',
        'preflightParentLinksMatch','preflightValidatorLineageMatch','preflightPlanContractMatch',
        'preflightPlanControlsMatch','preflightPlanSecurityMatch','preflightScriptEncodingMatch',
        'preflightBudgetDateMatch','preflightTimezoneMatch','preflightSameUserOwnerSid',
        'preflightSecretOutsideRepo','preflightSecretOutsideOneDrive','preflightSecretNoReparse',
        'preflightKeyRoundTrip','preflightServiceKeyCount','preflightOfflineMatrixPass',
        'preflightPass','nonSecretPreflightPass','c12PreRawRepo','c12PreEncodedRepo',
        'c12PreRawEnv','c12PreEncodedEnv','c12PreScanErrors','c12PostRawRepo',
        'c12PostEncodedRepo','c12PostRawEnv','c12PostEncodedEnv','c12PostScanErrors','c12Pass',
        'secretReferencesCleared','bstrZeroFreeSucceeded','errorBufferCleared','cleanupFailure',
        'runtimeSecretScanPass','outputAllowlistPass','securityConformance','planConformance',
        'runClosed','cumulativeCalls'
    )
    $allowed = @{}
    foreach ($name in $allowedNames) {
        $allowed[$name] = $true
    }

    $properties = if ($Record -is [Collections.IDictionary]) {
        @($Record.GetEnumerator() | ForEach-Object {
            [pscustomobject]@{ Name = [string]$_.Key; Value = $_.Value }
        })
    }
    else {
        @($Record.PSObject.Properties)
    }

    foreach ($property in $properties) {
        if (-not $allowed.ContainsKey([string]$property.Name)) {
            return $false
        }
        $values = @($property.Value)
        if ($values.Count -gt 256) {
            return $false
        }
        foreach ($value in $values) {
            if ($null -eq $value -or $value -is [bool] -or
                $value -is [byte] -or $value -is [int16] -or $value -is [int32] -or
                $value -is [int64] -or $value -is [uint16] -or $value -is [uint32] -or
                $value -is [uint64] -or $value -is [double] -or $value -is [decimal]) {
                continue
            }
            if (-not ($value -is [string])) {
                return $false
            }
            $textValue = [string]$value
            if ($textValue.Length -gt 256 -or $textValue -notmatch '^[A-Za-z0-9_./:+-]*$') {
                return $false
            }
        }
    }
    return $true
}

$finalResult = $null
$scriptHash = Get-FileSha256 $PSCommandPath

if ($OfflineSelfTest -and -not $Execute) {
    $matrix = Invoke-OfflineValidatorMatrix
    $finalResult = [ordered]@{
        mode = 'offline_self_test'
        scriptSha256 = $scriptHash
        validatorId = $matrix.validatorId
        fixtureCount = $matrix.fixtureCount
        fixtureDescriptorSha256 = $matrix.fixtureDescriptorSha256
        resultProjectionSha256 = $matrix.resultProjectionSha256
        allExpected = $matrix.allExpected
        unhandledCount = $matrix.unhandledCount
        networkCalls = 0
        pass = ($matrix.allExpected -and $matrix.unhandledCount -eq 0)
    }
}
elseif ($Execute -and -not $OfflineSelfTest) {
    $repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
    $secretPath = [IO.Path]::GetFullPath((
        Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'NowSignal\Secrets\data-go-kr.clixml'
    ))
    $credential = $null
    $secureKey = $null
    $bstr = [IntPtr]::Zero
    $bstrAllocated = $false
    $bstrZeroFreeSucceeded = $false
    $plainKey = $null
    $encodedKey = $null
    $query = $null
    $fullUri = $null
    $request = $null
    $response = $null
    $responseStream = $null
    $body = $null
    $publicParameters = $null
    $pairs = $null
    $validation = $null
    $safeProjection = $null
    $exceptionRecord = $null
    $preC12 = $null
    $postC12 = $null
    $networkCalls = 0
    $failureStage = 'plan_preflight'
    $preflightPass = $false
    $secretReferencesCleared = $false
    $scriptHashAfter = $null
    $httpStatus = $null
    $providerCode = $null
    $runtimeResult = $null
    $stopwatch = [Diagnostics.Stopwatch]::StartNew()

    $planHashMatch = $false
    $scriptHashMatch = $false
    $parentLinksMatch = $false
    $validatorLineageMatch = $false
    $planContractMatch = $false
    $planControlsMatch = $false
    $planSecurityMatch = $false
    $scriptEncodingMatch = $false
    $nonSecretPreflightPass = $false
    $runtimeSecretScanPass = $false
    $errorBufferCleared = $false
    $cleanupFailure = $false
    $budgetDateMatch = $false
    $timezoneMatch = $false
    $sameUserOwnerSid = $false
    $secretOutsideRepo = $false
    $secretOutsideOneDrive = $false
    $secretNoReparse = $false
    $secretMetadataPreflightPass = $false
    $keyRoundTrip = $false
    $serviceKeyCount = 0
    $offlineMatrixPass = $false

    try {
        if ([string]::IsNullOrWhiteSpace($ExpectedPlanHash) -or $ExpectedPlanHash -notmatch '^[0-9a-f]{64}$') {
            throw [InvalidDataException]::new('expected_plan_hash_invalid')
        }

        $runbookPath = Join-Path $repoRoot 'docs\provider-validation-runbook.md'
        $runbookText = [IO.File]::ReadAllText($runbookPath, [Text.Encoding]::UTF8)
        $anchor = $runbookText.IndexOf('Run 9 public plan canonical json')
        if ($anchor -lt 0) {
            throw [IO.InvalidDataException]::new('run9_plan_anchor_missing')
        }
        $planTail = $runbookText.Substring($anchor)
        $planMatch = [regex]::Match($planTail, '```json\r?\n([^\r\n]+)\r?\n```')
        if (-not $planMatch.Success) {
            throw [IO.InvalidDataException]::new('run9_plan_missing')
        }
        $canonicalPlan = $planMatch.Groups[1].Value
        $computedPlanHash = Get-TextSha256 $canonicalPlan
        $recordedPlanHash = ([regex]::Match(
            $planTail,
            'Run 9 public plan SHA-256: `([0-9a-f]{64})`'
        )).Groups[1].Value
        $plan = ConvertFrom-Json -InputObject $canonicalPlan
        $planHashMatch = (
            $computedPlanHash -eq $ExpectedPlanHash -and
            $recordedPlanHash -eq $ExpectedPlanHash
        )
        $scriptHashMatch = (
            $scriptHash -eq [string]$plan.scriptSha256 -and
            [string]$plan.scriptPath -eq 'scripts/validation/airkorea-contract-smoke.ps1'
        )
        $parentLinksMatch = (
            [string]$plan.parentPlanId -eq 'contract-smoke-20260810-v8' -and
            [string]$plan.parentRunId -eq $ParentRunId -and
            [string]$plan.parentPlanSha256 -eq '35cb9bdeb0d3531a4f0ce63673eca385f384d80804e9e95df8cb93aab32b9c20' -and
            [string]$plan.parentManifestSha256 -eq 'dc6c61a2488f97dda6975aec43bfe1b6bfc4f4e08ee20277ab5cddd5938d085f' -and
            [string]$plan.parentOutcome -eq 'preflight_aborted_path_traversal_validator_error_network0'
        )

        $planParameterProjection = [string]::Join('|', @(
            @($plan.parameters) | ForEach-Object {
                '{0}={1}' -f [string]$_[0], [string]$_[1]
            }
        ))
        $planQueryOrderProjection = [string]::Join('|', @($plan.queryParameterOrder))
        $planRequiredSchemaProjection = [string]::Join('|', @($plan.requiredSchema))
        $planDecompressionProjection = [string]::Join('|', @($plan.automaticDecompression))
        $planC12ScopeProjection = [string]::Join('|', @($plan.c12Scope))
        $planC12RepresentationProjection = [string]::Join('|', @($plan.c12Representations))
        $expectedParameterProjection = (
            'returnType=json|numOfRows=1|pageNo=1|stationName={0}|dataTerm=DAILY|ver=1.3' -f $StationName
        )
        $validatorLineageMatch = (
            [string]$plan.validatorId -eq $ValidatorId -and
            [string]$plan.parentValidatorFixtureDescriptorSha256 -eq $ParentFixtureDescriptorHash -and
            [string]$plan.parentValidatorResultProjectionSha256 -eq $ParentFixtureResultHash
        )
        $planContractMatch = (
            [string]$plan.planId -eq $PlanId -and
            [string]$plan.runId -eq $RunId -and
            [string]$plan.scheme -eq 'https' -and
            [string]$plan.host -eq 'apis.data.go.kr' -and
            [string]$plan.endpointPath -eq $ServicePath -and
            [string]$plan.method -eq 'GET' -and
            [string]$plan.requestBody -eq 'none' -and
            $planParameterProjection -eq $expectedParameterProjection -and
            [string]$plan.keyParameter -eq 'serviceKey' -and
            $planQueryOrderProjection -eq 'serviceKey|returnType|numOfRows|pageNo|stationName|dataTerm|ver' -and
            $planRequiredSchemaProjection -eq 'stationName|dataTime|pm10Value|pm25Value'
        )
        $planControlsMatch = (
            [string]$plan.ownerApproval -eq 'run8_single_call_approval_unconsumed_network0' -and
            [string]$plan.resumptionReason -eq 'run8_preflight_aborted_network0_local_path_traversal_fixed' -and
            [string]$plan.transport -eq 'HttpWebRequest' -and
            [string]$plan.executionMode -eq 'local_sentinel' -and
            [int]$plan.sentinelCalls -eq 1 -and
            [int]$plan.networkCallUpperBound -eq 1 -and
            [int]$plan.networkCallSiteUpperBound -eq 1 -and
            [int]$plan.retry -eq 0 -and
            [int]$plan.parallel -eq 0 -and
            [int]$plan.redirect -eq 0 -and
            [int]$plan.timeoutSeconds -eq 15 -and
            [int]$plan.readWriteTimeoutSeconds -eq 15 -and
            [int]$plan.responseLimitBytes -eq $ResponseLimitBytes -and
            $planDecompressionProjection -eq 'GZip|Deflate' -and
            -not [bool]$plan.keepAlive -and
            [int]$plan.hardCap -eq 30 -and
            [bool]$plan.processIsolation -and
            -not [bool]$plan.rawResponseStorage -and
            -not [bool]$plan.fullUrlStorage -and
            [string]$plan.successCriteria -eq 'http200_provider00_json_items_required_schema' -and
            [bool]$plan.stopAfterFirstAttempt
        )
        $planSecurityMatch = (
            [string]$plan.keySource -eq 'windows_current_user_dpapi_external_to_repo' -and
            [bool]$plan.sameUserSidRequired -and
            [bool]$plan.secretPathOutsideRepoAndOneDriveRequired -and
            [bool]$plan.secretNoReparseRequired -and
            [bool]$plan.secretMetadataGateBeforeImport -and
            [string]$plan.keyEncoding -eq 'decode_then_EscapeDataString_once' -and
            [int]$plan.serviceKeyCountRequired -eq 1 -and
            [bool]$plan.keyRoundTripRequired -and
            [bool]$plan.prePostC12 -and
            $planC12ScopeProjection -eq 'tracked|untracked|environment' -and
            $planC12RepresentationProjection -eq 'raw|url_encoded_once' -and
            [bool]$plan.c12ScanErrorsMustBeZero -and
            [bool]$plan.abortOnC12NonZero -and
            [bool]$plan.runtimeOutputSecretScanRequired -and
            [bool]$plan.errorBufferClearRequired -and
            [bool]$plan.zeroFreeBstrRequired -and
            [bool]$plan.cleanupFailureMustBeFalse -and
            [int]$plan.exceptionMaxDepth -eq 5 -and
            [string]$plan.exceptionPolicy -eq 'preserve_first_WebException_and_deepest_class' -and
            [string]$plan.consoleOutput -eq 'single_sanitized_json_allowlist_only'
        )

        $scriptBytes = [IO.File]::ReadAllBytes($PSCommandPath)
        $hasUtf8Bom = (
            $scriptBytes.Length -ge 3 -and
            $scriptBytes[0] -eq 0xEF -and $scriptBytes[1] -eq 0xBB -and $scriptBytes[2] -eq 0xBF
        )
        $hasCarriageReturn = (@($scriptBytes | Where-Object { $_ -eq 0x0D }).Count -gt 0)
        $hasNonAscii = (@($scriptBytes | Where-Object { $_ -gt 0x7F }).Count -gt 0)
        $scriptEncodingMatch = (
            -not $hasUtf8Bom -and -not $hasCarriageReturn -and -not $hasNonAscii -and
            [string]$plan.scriptEncoding -eq 'utf8_no_bom_lf_ascii_compatible' -and
            [string]$plan.scriptHashMode -eq 'raw_file_bytes'
        )
        $scriptBytes = $null

        $matrix = Invoke-OfflineValidatorMatrix
        $offlineMatrixPass = (
            $matrix.allExpected -and
            $matrix.unhandledCount -eq 0 -and
            $matrix.fixtureCount -eq 25 -and
            [int]$plan.validatorFixtureCount -eq 25 -and
            $matrix.fixtureDescriptorSha256 -eq [string]$plan.validatorFixtureDescriptorSha256 -and
            $matrix.resultProjectionSha256 -eq [string]$plan.validatorResultProjectionSha256
        )

        $now = Get-Date
        $budgetDateMatch = (
            $now.ToString('yyyy-MM-dd') -eq [string]$plan.budgetDate -and
            [int]$plan.preCallCount -eq $PreCallCount -and
            [int]$plan.expectedPostCallCount -eq 10
        )
        $timezoneMatch = ($now.ToString('zzz') -eq '+09:00')

        $nonSecretPreflightPass = (
            $planHashMatch -and $scriptHashMatch -and $scriptEncodingMatch -and
            $parentLinksMatch -and $validatorLineageMatch -and
            $planContractMatch -and $planControlsMatch -and $planSecurityMatch -and
            $offlineMatrixPass -and $budgetDateMatch -and $timezoneMatch
        )
        if (-not $nonSecretPreflightPass) {
            throw [IO.InvalidDataException]::new('non_secret_preflight_failed')
        }

        if (-not [IO.File]::Exists($secretPath)) {
            throw [IO.FileNotFoundException]::new('secret_file_missing')
        }
        $secretOutsideRepo = -not $secretPath.StartsWith($repoRoot, [StringComparison]::OrdinalIgnoreCase)
        $secretOutsideOneDrive = ($secretPath.IndexOf('\OneDrive\', [StringComparison]::OrdinalIgnoreCase) -lt 0)

        $secretNoReparse = $true
        $cursor = Get-Item -LiteralPath $secretPath -Force
        for ($depth = 0; $depth -lt 16 -and $null -ne $cursor; $depth++) {
            if (($cursor.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
                $secretNoReparse = $false
            }
            $cursor = if ($cursor -is [IO.FileInfo]) {
                $cursor.Directory
            }
            else {
                $cursor.Parent
            }
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
        $sameUserOwnerSid = ($null -ne $ownerSid -and $currentSid -eq $ownerSid)
        $ownerText = $null
        $ownerSid = $null
        $currentSid = $null

        $secretMetadataPreflightPass = (
            $sameUserOwnerSid -and $secretOutsideRepo -and
            $secretOutsideOneDrive -and $secretNoReparse
        )
        if (-not $secretMetadataPreflightPass) {
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

        $failureStage = 'c12_pre'
        $preC12 = Get-C12Counts $plainKey $encodedKey $repoRoot
        if ((
            $preC12.rawRepo + $preC12.encodedRepo +
            $preC12.rawEnv + $preC12.encodedEnv + $preC12.scanErrors
        ) -ne 0) {
            throw [Security.SecurityException]::new('c12_pre_failed')
        }

        $failureStage = 'request_build'
        $publicParameters = [ordered]@{
            returnType = 'json'
            numOfRows = '1'
            pageNo = '1'
            stationName = $StationName
            dataTerm = 'DAILY'
            ver = '1.3'
        }
        $pairs = New-Object 'System.Collections.Generic.List[string]'
        [void]$pairs.Add(('serviceKey={0}' -f $encodedKey))
        foreach ($entry in $publicParameters.GetEnumerator()) {
            [void]$pairs.Add(('{0}={1}' -f
                [Uri]::EscapeDataString([string]$entry.Key),
                [Uri]::EscapeDataString([string]$entry.Value)
            ))
        }
        $query = [string]::Join('&', $pairs)
        $serviceKeyCount = ([regex]::Matches($query, '(?:^|&)serviceKey=')).Count
        if ($serviceKeyCount -ne 1 -or -not $keyRoundTrip) {
            throw [IO.InvalidDataException]::new('query_secret_control_failed')
        }

        $preflightPass = (
            $nonSecretPreflightPass -and
            $sameUserOwnerSid -and $secretOutsideRepo -and
            $secretOutsideOneDrive -and $secretNoReparse -and
            $keyRoundTrip -and $serviceKeyCount -eq 1
        )
        if (-not $preflightPass) {
            throw [InvalidOperationException]::new('preflight_failed')
        }

        $fullUri = $EndpointUri + '?' + $query
        $request = [Net.HttpWebRequest]::Create($fullUri)
        $request.Method = 'GET'
        $request.Accept = 'application/json'
        $request.UserAgent = 'NowSignal-contract-smoke/1.0'
        $request.AllowAutoRedirect = $false
        $request.Timeout = 15000
        $request.ReadWriteTimeout = 15000
        $request.KeepAlive = $false
        $request.AutomaticDecompression = (
            [Net.DecompressionMethods]::GZip -bor [Net.DecompressionMethods]::Deflate
        )

        $failureStage = 'send'
        $networkCalls++
        $response = [Net.HttpWebResponse]$request.GetResponse()
        $httpStatus = [int]$response.StatusCode
        if ($httpStatus -ge 300 -and $httpStatus -lt 400) {
            throw [Net.WebException]::new('redirect_blocked', [Net.WebExceptionStatus]::ProtocolError)
        }
        if ($response.ContentLength -gt $ResponseLimitBytes) {
            throw [IO.InvalidDataException]::new('response_limit_exceeded')
        }

        $failureStage = 'read'
        $responseStream = $response.GetResponseStream()
        $body = Read-LimitedUtf8 $responseStream $ResponseLimitBytes
        $responseBytes = [Text.Encoding]::UTF8.GetByteCount($body)

        $failureStage = 'validate'
        $validation = ConvertTo-SafeValidationResult $body
        $providerCode = $validation.providerCode
        $safeProjection = [string]::Join('|', @(
            $EndpointPath, [string]$httpStatus, [string]$providerCode,
            [string]$validation.itemCount, [string]$validation.c01,
            [string]$validation.schemaStatus, [string]$validation.stationMatch,
            [string]$validation.dataTimeParseable,
            [string]$validation.observationAgeMinutes,
            [string]$validation.freshnessStatus,
            [string]$validation.qualityStatus
        ) + @($validation.fieldSignature) + @('NULLS') + @($validation.nullFields) +
            @('MISSING_VALUES') + @($validation.missingValueFields))

        $runtimeResult = [ordered]@{
            planId = $PlanId
            runId = $RunId
            parentRunId = $ParentRunId
            evaluatedAt = (Get-Date).ToString('yyyy-MM-ddTHH:mm:sszzz')
            phase = 'completed'
            networkCalls = $networkCalls
            endpointPath = $EndpointPath
            httpStatus = $httpStatus
            providerCode = $providerCode
            providerHeaderStatus = $validation.providerHeaderStatus
            jsonHeaderParse = $validation.jsonHeaderParse
            dataBodyStatus = $validation.dataBodyStatus
            schemaStatus = $validation.schemaStatus
            itemCount = $validation.itemCount
            missingRequiredFields = @($validation.missingFields)
            fieldSignature = @($validation.fieldSignature)
            nullFields = @($validation.nullFields)
            missingValueFields = @($validation.missingValueFields)
            stationMatch = $validation.stationMatch
            dataTimeParseable = $validation.dataTimeParseable
            observationAgeMinutes = $validation.observationAgeMinutes
            freshnessStatus = $validation.freshnessStatus
            qualityStatus = $validation.qualityStatus
            responseBytes = $responseBytes
            sanitizedProjectionSha256 = Get-TextSha256 $safeProjection
            localValidator = if ($validation.errorClass -eq 'validator_unhandled') { 'fail' } else { 'pass' }
            providerContractVerdict = if ($validation.errorClass -eq 'validator_unhandled') {
                'not_evaluable'
            }
            elseif ($validation.c01 -eq 'pass') {
                'pass'
            }
            else {
                'fail'
            }
            resultKind = $validation.resultKind
            errorClass = $validation.errorClass
            c01 = $validation.c01
            c09 = 'not_run'
            c10 = 'not_run'
            retry = 0
            redirect = 0
            rawResponseStored = $false
            fullUrlStored = $false
        }
    }
    catch {
        try {
            $exceptionRecord = Get-SanitizedExceptionRecord $_.Exception
            if (-not $exceptionRecord.webResponseDisposeSucceeded) {
                $cleanupFailure = $true
            }
            if ($null -ne $response) {
                $httpStatus = [int]$response.StatusCode
            }
            if ($null -ne $exceptionRecord.httpStatus) {
                $httpStatus = [int]$exceptionRecord.httpStatus
            }

            $errorClass = if ($networkCalls -eq 0) {
                'aborted_preflight'
            }
            elseif ($httpStatus -eq 504) {
                'http_504_gateway_timeout_origin_unclassified'
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
            elseif ($null -ne $httpStatus -and $httpStatus -ge 300 -and $httpStatus -lt 400) {
                'unexpected_redirect'
            }
            elseif ($exceptionRecord.webExceptionStatus -eq 'Timeout') {
                'client_timeout'
            }
            elseif ($failureStage -eq 'validate') {
                'local_validator_unhandled'
            }
            elseif ($failureStage -eq 'read') {
                'response_read_error'
            }
            elseif ($null -ne $httpStatus) {
                'http_error_unclassified'
            }
            else {
                'transport_error_unclassified'
            }

            $runtimeResult = [ordered]@{
                planId = $PlanId
                runId = $RunId
                parentRunId = $ParentRunId
                evaluatedAt = (Get-Date).ToString('yyyy-MM-ddTHH:mm:sszzz')
                phase = $failureStage
                networkCalls = $networkCalls
                endpointPath = $EndpointPath
                httpStatus = $httpStatus
                providerCode = $providerCode
                providerHeaderStatus = 'not_observed'
                jsonHeaderParse = 'not_observed'
                dataBodyStatus = 'not_observed'
                schemaStatus = 'not_observed'
                outerErrorClass = $exceptionRecord.outerClass
                rootErrorClass = $exceptionRecord.rootClass
                innerDepth = $exceptionRecord.innerDepth
                chainTruncated = $exceptionRecord.chainTruncated
                webExceptionStatus = $exceptionRecord.webExceptionStatus
                localValidator = if ($failureStage -eq 'validate') { 'fail' } else { 'not_run' }
                providerContractVerdict = 'not_evaluable'
                resultKind = if ($networkCalls -eq 0) { 'not_run' } else { 'unavailable' }
                errorClass = $errorClass
                c01 = if ($networkCalls -eq 0) { 'not_run' } else { 'fail' }
                c09 = 'not_run'
                c10 = 'not_run'
                retry = 0
                redirect = 0
                rawResponseStored = $false
                fullUrlStored = $false
            }
            $exceptionRecord = $null
        }
        catch {
            $cleanupFailure = $true
            $exceptionRecord = $null
            $runtimeResult = [ordered]@{
                planId = $PlanId; runId = $RunId; phase = 'exception_sanitize'
                networkCalls = $networkCalls; endpointPath = $EndpointPath
                resultKind = if ($networkCalls -eq 0) { 'not_run' } else { 'unavailable' }
                errorClass = 'sanitized_exception_handler_error'
                c01 = if ($networkCalls -eq 0) { 'not_run' } else { 'fail' }
                c09 = 'not_run'; c10 = 'not_run'; retry = 0; redirect = 0
                rawResponseStored = $false; fullUrlStored = $false
            }
        }
    }
    finally {
        try {
            $stopwatch.Stop()
        }
        catch {
            $cleanupFailure = $true
        }
        try {
            if ($null -ne $plainKey -and $null -ne $encodedKey -and $null -ne $runtimeResult) {
                $runtimeCandidate = [pscustomobject]$runtimeResult | ConvertTo-Json -Compress -Depth 7
                $encodedLowerEscapes = [regex]::Replace(
                    $encodedKey,
                    '%[0-9A-F]{2}',
                    { param($match) $match.Value.ToLowerInvariant() }
                )
                $secretOccurrenceCount = (
                    (Get-OccurrenceCount $runtimeCandidate $plainKey) +
                    (Get-OccurrenceCount $runtimeCandidate $encodedKey) +
                    (Get-OccurrenceCount $runtimeCandidate $encodedLowerEscapes)
                )
                if ($null -ne $fullUri) {
                    $secretOccurrenceCount += Get-OccurrenceCount $runtimeCandidate $fullUri
                }
                if ($null -ne $body -and $body.Length -gt 0) {
                    $secretOccurrenceCount += Get-OccurrenceCount $runtimeCandidate $body
                }
                $runtimeSecretScanPass = (
                    $secretOccurrenceCount -eq 0 -and
                    $runtimeCandidate -notmatch 'https?://' -and
                    $runtimeCandidate -notmatch 'serviceKey=' -and
                    $runtimeCandidate -notmatch 'S-1-[0-9-]+' -and
                    $runtimeCandidate -notmatch '\\Users\\' -and
                    $runtimeCandidate -notmatch '\\OneDrive\\'
                )
                $runtimeCandidate = $null
                $encodedLowerEscapes = $null
            }
        }
        catch {
            $runtimeSecretScanPass = $false
        }
        try {
            if ($null -ne $plainKey -and $null -ne $encodedKey) {
                $postC12 = Get-C12Counts $plainKey $encodedKey $repoRoot
            }
        }
        catch {
            $postC12 = $null
        }

        try {
            if ($null -ne $responseStream) {
                $responseStream.Dispose()
            }
        }
        catch {
            $cleanupFailure = $true
        }
        try {
            if ($null -ne $response) {
                $response.Dispose()
            }
        }
        catch {
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

        try {
            if ($null -ne $pairs) {
                $pairs.Clear()
            }
        }
        catch {
            $cleanupFailure = $true
        }
        try {
            if ($null -ne $publicParameters) {
                $publicParameters.Clear()
            }
        }
        catch {
            $cleanupFailure = $true
        }

        $body = $null
        $responseStream = $null
        $fullUri = $null
        $query = $null
        $pairs = $null
        $publicParameters = $null
        $request = $null
        $response = $null
        $validation = $null
        $safeProjection = $null
        $exceptionRecord = $null
        $encodedKey = $null
        $plainKey = $null
        $secureKey = $null
        $credential = $null
        $secretReferencesCleared = (
            $bstrZeroFreeSucceeded -and $bstr -eq [IntPtr]::Zero -and $null -eq $pairs -and
            $null -eq $query -and $null -eq $fullUri -and
            $null -eq $request -and $null -eq $response -and
            $null -eq $encodedKey -and $null -eq $plainKey -and
            $null -eq $secureKey -and $null -eq $credential -and
            $null -eq $exceptionRecord
        )
        try {
            $scriptHashAfter = Get-FileSha256 $PSCommandPath
        }
        catch {
            $scriptHashAfter = $null
            $cleanupFailure = $true
        }
        try {
            $Error.Clear()
            $errorBufferCleared = ($Error.Count -eq 0)
        }
        catch {
            $errorBufferCleared = $false
            $cleanupFailure = $true
        }
    }

    try {
        if ($null -eq $runtimeResult) {
            $runtimeResult = [ordered]@{
                planId = $PlanId; runId = $RunId; phase = 'internal'
                networkCalls = $networkCalls; endpointPath = $EndpointPath
                resultKind = 'not_run'; errorClass = 'internal_result_missing'
                c01 = 'not_run'; c09 = 'not_run'; c10 = 'not_run'
                retry = 0; redirect = 0; rawResponseStored = $false; fullUrlStored = $false
            }
        }

        $runtimeResult.planSha256 = $ExpectedPlanHash
        $runtimeResult.scriptSha256 = $scriptHash
        $runtimeResult.scriptHashBeforeMatch = $scriptHashMatch
        $runtimeResult.scriptHashAfterMatch = ($scriptHashAfter -eq $scriptHash)
        $runtimeResult.durationMs = $stopwatch.ElapsedMilliseconds
        $runtimeResult.preflightPlanHashMatch = $planHashMatch
        $runtimeResult.preflightParentLinksMatch = $parentLinksMatch
        $runtimeResult.preflightValidatorLineageMatch = $validatorLineageMatch
        $runtimeResult.preflightPlanContractMatch = $planContractMatch
        $runtimeResult.preflightPlanControlsMatch = $planControlsMatch
        $runtimeResult.preflightPlanSecurityMatch = $planSecurityMatch
        $runtimeResult.preflightScriptEncodingMatch = $scriptEncodingMatch
        $runtimeResult.preflightBudgetDateMatch = $budgetDateMatch
        $runtimeResult.preflightTimezoneMatch = $timezoneMatch
        $runtimeResult.preflightSameUserOwnerSid = $sameUserOwnerSid
        $runtimeResult.preflightSecretOutsideRepo = $secretOutsideRepo
        $runtimeResult.preflightSecretOutsideOneDrive = $secretOutsideOneDrive
        $runtimeResult.preflightSecretNoReparse = $secretNoReparse
        $runtimeResult.preflightKeyRoundTrip = $keyRoundTrip
        $runtimeResult.preflightServiceKeyCount = $serviceKeyCount
        $runtimeResult.preflightOfflineMatrixPass = $offlineMatrixPass
        $runtimeResult.preflightPass = $preflightPass
        $runtimeResult.nonSecretPreflightPass = $nonSecretPreflightPass
        $runtimeResult.c12PreRawRepo = if ($null -eq $preC12) { $null } else { $preC12.rawRepo }
        $runtimeResult.c12PreEncodedRepo = if ($null -eq $preC12) { $null } else { $preC12.encodedRepo }
        $runtimeResult.c12PreRawEnv = if ($null -eq $preC12) { $null } else { $preC12.rawEnv }
        $runtimeResult.c12PreEncodedEnv = if ($null -eq $preC12) { $null } else { $preC12.encodedEnv }
        $runtimeResult.c12PreScanErrors = if ($null -eq $preC12) { $null } else { $preC12.scanErrors }
        $runtimeResult.c12PostRawRepo = if ($null -eq $postC12) { $null } else { $postC12.rawRepo }
        $runtimeResult.c12PostEncodedRepo = if ($null -eq $postC12) { $null } else { $postC12.encodedRepo }
        $runtimeResult.c12PostRawEnv = if ($null -eq $postC12) { $null } else { $postC12.rawEnv }
        $runtimeResult.c12PostEncodedEnv = if ($null -eq $postC12) { $null } else { $postC12.encodedEnv }
        $runtimeResult.c12PostScanErrors = if ($null -eq $postC12) { $null } else { $postC12.scanErrors }

        $c12Pass = (
            $null -ne $preC12 -and $null -ne $postC12 -and
            ($preC12.rawRepo + $preC12.encodedRepo +
             $preC12.rawEnv + $preC12.encodedEnv + $preC12.scanErrors +
             $postC12.rawRepo + $postC12.encodedRepo +
             $postC12.rawEnv + $postC12.encodedEnv + $postC12.scanErrors) -eq 0
        )
        $runtimeResult.c12Pass = $c12Pass
        $runtimeResult.secretReferencesCleared = $secretReferencesCleared
        $runtimeResult.bstrZeroFreeSucceeded = $bstrZeroFreeSucceeded
        $runtimeResult.errorBufferCleared = $errorBufferCleared
        $runtimeResult.cleanupFailure = $cleanupFailure
        $runtimeResult.runtimeSecretScanPass = $runtimeSecretScanPass
        $outputAllowlistPass = Test-SafeOutputRecord $runtimeResult
        $runtimeResult.outputAllowlistPass = $outputAllowlistPass
        $runtimeResult.securityConformance = if (
            $preflightPass -and $c12Pass -and $secretReferencesCleared -and
            $bstrZeroFreeSucceeded -and $errorBufferCleared -and
            -not $cleanupFailure -and $runtimeSecretScanPass -and
            $outputAllowlistPass -and $scriptHashAfter -eq $scriptHash -and
            $networkCalls -eq 1
        ) { 'pass' } else { 'fail' }
        $runtimeResult.planConformance = if (
            $networkCalls -eq 1 -and $runtimeResult.retry -eq 0 -and
            $runtimeResult.redirect -eq 0 -and $runtimeResult.securityConformance -eq 'pass'
        ) { 'pass' } else { 'fail' }
        $runtimeResult.runClosed = $true
        $runtimeResult.cumulativeCalls = $PreCallCount + $networkCalls

        if (-not (Test-SafeOutputRecord $runtimeResult)) {
            $runtimeResult = [ordered]@{
                planId = $PlanId; runId = $RunId; phase = 'sanitize'
                networkCalls = $networkCalls; endpointPath = $EndpointPath
                resultKind = if ($networkCalls -eq 0) { 'not_run' } else { 'unavailable' }
                errorClass = 'output_allowlist_rejected'; c01 = 'fail'
                c09 = 'not_run'; c10 = 'not_run'; retry = 0; redirect = 0
                rawResponseStored = $false; fullUrlStored = $false
                outputAllowlistPass = $false; securityConformance = 'fail'
                planConformance = 'fail'; runClosed = $true
                cumulativeCalls = $PreCallCount + $networkCalls
            }
        }
        $finalResult = $runtimeResult
    }
    catch {
        $finalResult = [ordered]@{
            planId = $PlanId; runId = $RunId; phase = 'sanitize'
            networkCalls = $networkCalls; endpointPath = $EndpointPath
            resultKind = if ($networkCalls -eq 0) { 'not_run' } else { 'unavailable' }
            errorClass = 'sanitized_finalization_error'; c01 = 'fail'
            c09 = 'not_run'; c10 = 'not_run'; retry = 0; redirect = 0
            rawResponseStored = $false; fullUrlStored = $false
            outputAllowlistPass = $false; securityConformance = 'fail'
            planConformance = 'fail'; runClosed = $true
            cumulativeCalls = $PreCallCount + $networkCalls
        }
    }
}
else {
    $finalResult = [ordered]@{
        mode = 'invalid_mode'
        scriptSha256 = $scriptHash
        networkCalls = 0
        pass = $false
    }
}

try {
    $serializedResult = [pscustomobject]$finalResult | ConvertTo-Json -Compress -Depth 7
    [Console]::Out.WriteLine($serializedResult)
}
catch {
    $terminalNetworkCalls = 0
    try {
        $candidateNetworkCalls = [int]$networkCalls
        if ($candidateNetworkCalls -ge 0 -and $candidateNetworkCalls -le 1) {
            $terminalNetworkCalls = $candidateNetworkCalls
        }
    }
    catch {
    }
    [Console]::Out.WriteLine((
        '{"mode":"sanitized_terminal_error","networkCalls":{0},"pass":false}' -f
        $terminalNetworkCalls
    ))
}
