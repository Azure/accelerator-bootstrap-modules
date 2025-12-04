param(
    [string]$name,
    [string]$displayName,
    [string]$templateFilePath,
    [string]$templateParametersFilePath,
    [string]$managementGroupId,
    [string]$subscriptionId,
    [string]$resourceGroupName,
    [string]$location,
    [string]$deploymentType
)

# Resolve template paths relative to the script's parent directory (where templates folder is located)
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$templateRoot = Split-Path -Parent $scriptRoot
$templateFilePath = Join-Path $templateRoot $templateFilePath
$templateParametersFilePath = Join-Path $templateRoot $templateParametersFilePath

Write-Host "<---------------------------------------------------------------------------->" -ForegroundColor Blue
Write-Host "Starting deployment stack for $displayName..." -ForegroundColor Blue
Write-Host "<---------------------------------------------------------------------------->" -ForegroundColor Blue
Write-Host ""

Write-Host "Display Name: $displayName" -ForegroundColor DarkGray
Write-Host "Template File Path: $templateFilePath" -ForegroundColor DarkGray
Write-Host "Template Parameters File Path: $templateParametersFilePath" -ForegroundColor DarkGray
Write-Host "Management Group Id: $managementGroupId" -ForegroundColor DarkGray
Write-Host "Subscription Id: $subscriptionId" -ForegroundColor DarkGray
Write-Host "Resource Group Name: $resourceGroupName" -ForegroundColor DarkGray
Write-Host "Location: $location" -ForegroundColor DarkGray
Write-Host "Deployment Type: $deploymentType" -ForegroundColor DarkGray

$deploymentName = $name
Write-Host "Deployment Stack Name: $deploymentName"
Write-Host ""

# Check if template files exist
if (-not (Test-Path $templateFilePath)) {
    Write-Error "Template file not found: $templateFilePath"
    throw "Template file not found: $templateFilePath"
}
Write-Host "Template file exists: $templateFilePath" -ForegroundColor Green

if (-not (Test-Path $templateParametersFilePath)) {
    Write-Error "Template parameters file not found: $templateParametersFilePath"
    throw "Template parameters file not found: $templateParametersFilePath"
}
Write-Host "Template parameters file exists: $templateParametersFilePath" -ForegroundColor Green
Write-Host ""

$stackParameters = @{
    Name                  = $deploymentName
    TemplateFile          = $templateFilePath
    TemplateParameterFile = $templateParametersFilePath
    DenySettingsMode      = "None"
    ActionOnUnmanage      = "DeleteAll"
    Force                 = $true
    Verbose               = $true
}

$retryCount = 0
$retryMax = 10
$initialRetryDelay = 20
$retryDelayIncrement = 10
$finalSuccess = $false

while ($retryCount -lt $retryMax) {
    if ($retryCount -gt 0) {
        $retryDelay = $initialRetryDelay + ($retryCount * $retryDelayIncrement)
        Write-Host "Retrying deployment stack after $retryDelay seconds..." -ForegroundColor Green
        Start-Sleep -Seconds $retryDelay
        Write-Host "Retry attempt $retryCount" -ForegroundColor Green
    }

    $result = $null

    try {
        switch ($deploymentType) {
            "managementGroup" {
                $targetManagementGroupId = $managementGroupId
                if ([string]::IsNullOrWhiteSpace($targetManagementGroupId)) {
                    $targetManagementGroupId = (Get-AzContext).Tenant.TenantId
                }

                $result = New-AzManagementGroupDeploymentStack @stackParameters -ManagementGroupId $targetManagementGroupId -Location $location -Verbose
            }
            "subscription" {
                if (-not [string]::IsNullOrWhiteSpace($subscriptionId)) {
                    Select-AzSubscription -SubscriptionId $subscriptionId | Out-Null
                }

                $result = New-AzSubscriptionDeploymentStack @stackParameters -Location $location -Verbose
            }
            "resourceGroup" {
                if (-not [string]::IsNullOrWhiteSpace($subscriptionId)) {
                    Select-AzSubscription -SubscriptionId $subscriptionId | Out-Null
                }

                $result = New-AzResourceGroupDeploymentStack @stackParameters -ResourceGroupName $resourceGroupName -Location $location -Verbose
            }
            "tenant" {
                throw "Deployment stacks are not supported for tenant scoped deployments."
            }
            default {
                throw "Unsupported deployment type '$deploymentType' for deployment stacks."
            }
        }
    } catch {
        Write-Host $_ -ForegroundColor Red
        Write-Host "Deployment stack failed with exception, entering retry loop..." -ForegroundColor Red
        $retryCount++
        continue
    }

    if ($null -eq $result) {
        Write-Host "Deployment stack returned no result. Entering retry loop..." -ForegroundColor Red
        $retryCount++
        continue
    }

    Write-Host "Deployment Stack ID: $($result.Id)"
    Write-Host "Provisioning State: $($result.ProvisioningState)"

    if ($result.ProvisioningState -ne "succeeded") {
        Write-Host "Deployment stack provisioning did not succeed. Current state: $($result.ProvisioningState). Entering retry loop..." -ForegroundColor Red
        $retryCount++
    } else {
        $finalSuccess = $true
        break
    }
}

if($finalSuccess -eq $false) {
    Write-Error "Deployment stack failed after $retryMax attempts."
    exit 1
}

Write-Host "<---------------------------------------------------------------------------->" -ForegroundColor DarkMagenta
Write-Host "Completed deployment stack for $displayName." -ForegroundColor DarkMagenta
Write-Host "<---------------------------------------------------------------------------->" -ForegroundColor DarkMagenta
Write-Host ""
