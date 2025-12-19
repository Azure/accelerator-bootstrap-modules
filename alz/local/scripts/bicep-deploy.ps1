param(
    [switch]$whatIf,
    [string]$displayName,
    [string]$templateFilePath,
    [string]$templateParametersFilePath,
    [string]$managementGroupId,
    [string]$subscriptionId,
    [string]$resourceGroupName,
    [string]$location,
    [string]$deploymentType,
    [bool]$firstRunWhatIf,
    [bool]$firstDeployment
)

Write-Host "<---------------------------------------------------------------------------->" -ForegroundColor Blue
Write-Host "Starting $($whatIf ? "What If" : "Full") $displayName..." -ForegroundColor Blue
Write-Host "<---------------------------------------------------------------------------->" -ForegroundColor Blue
Write-Host ""

Write-Host "What If: $whatIf" -ForegroundColor DarkGray
Write-Host "Display Name: $displayName" -ForegroundColor DarkGray
Write-Host "Template File Path: $templateFilePath" -ForegroundColor DarkGray
Write-Host "Template Parameters File Path: $templateParametersFilePath" -ForegroundColor DarkGray
Write-Host "Management Group Id: $managementGroupId" -ForegroundColor DarkGray
Write-Host "Subscription Id: $subscriptionId" -ForegroundColor DarkGray
Write-Host "Resource Group Name: $resourceGroupName" -ForegroundColor DarkGray
Write-Host "Location: $location" -ForegroundColor DarkGray
Write-Host "Deployment Type: $deploymentType" -ForegroundColor DarkGray
Write-Host "First Run What If: $firstRunWhatIf" -ForegroundColor DarkGray
Write-Host "First Deployment: $firstDeployment" -ForegroundColor DarkGray

if($whatIf -and $firstDeployment -and !$firstRunWhatIf) {
    Write-Host "Skipping the WhatIf check as the deployment is dependent on resources that do not exist yet..." -ForegroundColor Cyan
    return
}

$deploymentPrefix = $env:PREFIX
$deploymentName = $displayName.Replace(" ", "-")
$deploymentTimeStamp = Get-Date -Format 'yyyyMMddHHmmss'

$prefixPostFixAndHythenLength = $deploymentPrefix.Length + $deploymentTimeStamp.Length + 2
$deploymentNameMaxLength = 61 - $prefixPostFixAndHythenLength

if($deploymentName.Length -gt $deploymentNameMaxLength) {
    $deploymentName = $deploymentName.Substring(0, $deploymentNameMaxLength)
}

$deploymentName = "$deploymentPrefix-$deploymentName-$deploymentTimeStamp"
Write-Host "Deployment Name: $deploymentName"

$inputObject = @{
    TemplateFile          = $templateFilePath
    TemplateParameterFile = $templateParametersFilePath
    WhatIf                = $whatIf
}

$retryCount = 0
$retryMax = 30
$initialRetryDelay = 20
$retryDelayIncrement = 10
$finalSuccess = $false

while ($retryCount -lt $retryMax) {
    $retryAttempt = '{0:d2}' -f ($retryCount + 1)

    if($retryCount -gt 0) {
        $retryDelay = $initialRetryDelay + ($retryCount * $retryDelayIncrement)
        Write-Host "Retrying deployment with attempt number $retryAttempt after $retryDelay seconds..." -ForegroundColor Green
        Start-Sleep -Seconds $retryDelay
        Write-Host "Retrying deployment..." -ForegroundColor Green
    }

    $inputObject.DeploymentName = "$deploymentName-$retryAttempt"

    $result = $null

    try {
        if ($deploymentType -eq "tenant") {
            $inputObject.Location = $location
            $result = New-AzTenantDeployment @inputObject
        }

        if ($deploymentType -eq "managementGroup") {
            $inputObject.Location = $location
            $inputObject.ManagementGroupId = $managementGroupId
            if ($inputObject.ManagementGroupId -eq "") {
                $inputObject.ManagementGroupId = (Get-AzContext).Tenant.TenantId
            }
            $result = New-AzManagementGroupDeployment @inputObject
        }

        if ($deploymentType -eq "subscription") {
            $inputObject.Location = $location
            Select-AzSubscription -SubscriptionId $subscriptionId
            $result = New-AzSubscriptionDeployment @inputObject
        }

        if ($deploymentType -eq "resourceGroup") {
            $inputObject.ResourceGroupName = $resourceGroupName
            Select-AzSubscription -SubscriptionId $subscriptionId
            $result = New-AzResourceGroupDeployment @inputObject
        }
    } catch {
        Write-Host $_ -ForegroundColor Red
        Write-Host "Deployment failed with exception, this is likely an intermittent failure so entering retry loop..." -ForegroundColor Red
        $retryCount++
        continue
    }

    if ($whatIf) {
        $result | Format-List | Out-Host
        return
    }

    $resultId = ""

    if($deploymentType -eq "resourceGroup") {
        $resultId = "/subscriptions/$($subscriptionId)/resourceGroups/$($resourceGroupName)/providers/Microsoft.Resources/deployments/$deploymentName"
    } else {
        $resultId = $result.Id
    }

    $resultIdEscaped = $resultId.Replace("/", "%2F")
    $resultUrl = "https://portal.azure.com/#view/HubsExtension/DeploymentDetailsBlade/~/overview/id/$resultIdEscaped"

    Write-Host "Deployment Name: $deploymentName"
    Write-Host "Deployment ID: $resultId"
    Write-Host "Deployment Url: $resultUrl"
    $result | Format-List | Out-Host

    if($result.ProvisioningState -ne "Succeeded") {
        Write-Host "Deployment failed with unsuccessful provisioning state, this is likely an intermittent failure so entering retry loop..." -ForegroundColor Red
        $retryCount++
    } else {
        $finalSuccess = $true
        break
    }
}

if($finalSuccess -eq $false) {
    Write-Error "Deployment failed after $retryMax attempts..."
}

Write-Host "<---------------------------------------------------------------------------->" -ForegroundColor DarkMagenta
Write-Host "Completed $($whatIf ? "What If" : "Full") $displayName..." -ForegroundColor DarkMagenta
Write-Host "<---------------------------------------------------------------------------->" -ForegroundColor DarkMagenta
Write-Host ""