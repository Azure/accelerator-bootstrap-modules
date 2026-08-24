param()

function Get-Sha256HashPrefix {
    param(
        [Parameter(Mandatory = $true)]
        [string]$InputString,
        [Parameter(Mandatory = $true)]
        [int]$Length
    )

    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hashBytes = $sha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($InputString))
    } finally {
        $sha256.Dispose()
    }

    return [System.BitConverter]::ToString($hashBytes).Replace("-", "").Substring(0, $Length).ToLower()
}

function New-RemoteDeterministicDeploymentStackName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DeploymentPrefix,
        [Parameter(Mandatory = $true)]
        [string]$OriginalName
    )

    $normalizedBase = $OriginalName
    if ([string]::IsNullOrWhiteSpace($normalizedBase)) {
        $normalizedBase = "deployment"
    }
    $normalizedBase = $normalizedBase.Replace(" ", "-")

    $hashLength = 10
    $hash = Get-Sha256HashPrefix -InputString "$DeploymentPrefix|$normalizedBase" -Length $hashLength

    $legacyName = "$DeploymentPrefix-$normalizedBase"
    if ($legacyName.Length -le 64) {
        return $legacyName
    }

    $safePrefix = $DeploymentPrefix
    $prefixMaxLength = [Math]::Max(1, 64 - $hashLength - 3)
    if ($safePrefix.Length -gt $prefixMaxLength) {
        $safePrefix = $safePrefix.Substring(0, $prefixMaxLength)
    }

    $baseMaxLength = [Math]::Max(1, 64 - $safePrefix.Length - $hashLength - 2)
    $safeBase = $normalizedBase
    if ($safeBase.Length -gt $baseMaxLength) {
        $safeBase = $safeBase.Substring(0, $baseMaxLength)
    }

    return "$safePrefix-$safeBase-$hash"
}

$localPrefix = "alzrishabh2705-long-management-group-id"
function New-LocalDeterministicDeploymentStackName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DeploymentPrefix,
        [Parameter(Mandatory = $true)]
        [string]$OriginalName
    )

    $normalizedBase = $OriginalName
    if ([string]::IsNullOrWhiteSpace($normalizedBase)) {
        $normalizedBase = "deployment"
    }
    $normalizedBase = $normalizedBase.Replace(" ", "-")

    if ($normalizedBase.Length -le 64) {
        return $normalizedBase
    }

    $hashLength = 10
    $hash = Get-Sha256HashPrefix -InputString "$DeploymentPrefix|$normalizedBase" -Length $hashLength

    $safePrefix = $DeploymentPrefix
    $prefixMaxLength = [Math]::Max(1, 64 - $hashLength - 3)
    if ($safePrefix.Length -gt $prefixMaxLength) {
        $safePrefix = $safePrefix.Substring(0, $prefixMaxLength)
    }

    $baseMaxLength = [Math]::Max(1, 64 - $safePrefix.Length - $hashLength - 2)
    $safeBase = $normalizedBase
    if ($safeBase.Length -gt $baseMaxLength) {
        $safeBase = $safeBase.Substring(0, $baseMaxLength)
    }

    return "$safePrefix-$safeBase-$hash"
}

$shortPrefix = "alz-short"
$shortBase = "deploy-stage-one"
$legacyExpected = "$shortPrefix-$shortBase"
$shortNameResult = New-RemoteDeterministicDeploymentStackName -DeploymentPrefix $shortPrefix -OriginalName $shortBase
Write-Host "Legacy-compatible Name: $shortNameResult"

if ($shortNameResult -ne $legacyExpected) {
    throw "Validation failed: expected legacy name '$legacyExpected' when length is <= 64."
}

if ($shortNameResult -match "-[a-f0-9]{10}$") {
    throw "Validation failed: hash suffix should not be added when legacy name length is <= 64."
}

$prefix = "alzrishabh2705-long-management-group-id"
$nameStageThree = "governance-landingzones-platform-deployment-stage-three"
$nameStageFour = "governance-landingzones-platform-deployment-stage-four"

$stackNameStageThree = New-RemoteDeterministicDeploymentStackName -DeploymentPrefix $prefix -OriginalName $nameStageThree
$stackNameStageFour = New-RemoteDeterministicDeploymentStackName -DeploymentPrefix $prefix -OriginalName $nameStageFour

Write-Host "Stage Three Name: $stackNameStageThree"
Write-Host "Stage Four Name:  $stackNameStageFour"

if ($stackNameStageThree -eq $stackNameStageFour) {
    throw "Validation failed: stage-three and stage-four produced the same deployment stack name."
}

if ($stackNameStageThree.Length -gt 64 -or $stackNameStageFour.Length -gt 64) {
    throw "Validation failed: one or more deployment stack names exceeded the 64 character limit."
}

if ($stackNameStageThree -notmatch "-[a-f0-9]{10}$" -or $stackNameStageFour -notmatch "-[a-f0-9]{10}$") {
    throw "Validation failed: long names should use the deterministic hash suffix."
}

$veryLongPrefix = "alzrishabh2705-super-long-management-group-prefix-with-extra-segments-over-limit"
$longPrefixName = New-RemoteDeterministicDeploymentStackName -DeploymentPrefix $veryLongPrefix -OriginalName $nameStageThree
Write-Host "Long Prefix Name: $longPrefixName"

if ($longPrefixName.Length -gt 64) {
    throw "Validation failed: long-prefix deployment stack name exceeded 64 characters."
}

if ($longPrefixName -notmatch "-[a-f0-9]{10}$") {
    throw "Validation failed: deployment stack name does not end with expected lowercase hash suffix."
}

$localShortName = "platform-stage-one"
$localShortNameResult = New-LocalDeterministicDeploymentStackName -DeploymentPrefix $localPrefix -OriginalName $localShortName
Write-Host "Local Legacy-compatible Name: $localShortNameResult"

if ($localShortNameResult -ne $localShortName) {
    throw "Validation failed: local short deployment stack names should remain unchanged."
}

if ($localShortNameResult -match "-[a-f0-9]{10}$") {
    throw "Validation failed: local short deployment stack names should not receive a hash suffix."
}

$localLongName = "governance-landingzones-platform-deployment-stage-three-with-extra-segments-over-the-azure-name-limit"
$localLongNameResult = New-LocalDeterministicDeploymentStackName -DeploymentPrefix $localPrefix -OriginalName $localLongName
Write-Host "Local Long Name: $localLongNameResult"

if ($localLongNameResult.Length -gt 64) {
    throw "Validation failed: local long deployment stack name exceeded 64 characters."
}

if ($localLongNameResult -notmatch "-[a-f0-9]{10}$") {
    throw "Validation failed: local long deployment stack names should use the deterministic hash suffix."
}

Write-Host "Validation passed: legacy-compatible naming is preserved and hash-suffix naming is unique and length-safe when required."
