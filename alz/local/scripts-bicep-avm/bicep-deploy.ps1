param(
    [string]$displayName,
    [string]$templateFilePath,
    [string]$templateParametersFilePath,
    [string]$managementGroupId,
    [string]$subscriptionId,
    [string]$resourceGroupName,
    [string]$location,
    [string]$deploymentType
)

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

$deploymentPrefix = $env:PREFIX
$deploymentName = $displayName.Replace(" ", "-")
$deploymentTimeStamp = Get-Date -Format 'yyyyMMddHHmmss'

$prefixPostFixAndHyphenLength = $deploymentPrefix.Length + $deploymentTimeStamp.Length + 2
$deploymentNameMaxLength = 61 - $prefixPostFixAndHyphenLength

if($deploymentName.Length -gt $deploymentNameMaxLength) {
    $deploymentName = $deploymentName.Substring(0, $deploymentNameMaxLength)
}

$deploymentName = "$deploymentPrefix-$deploymentName-$deploymentTimeStamp"
Write-Host "Deployment Stack Name: $deploymentName"

$stackParameters = @{
    Name                  = $deploymentName
    TemplateFile          = $templateFilePath
    TemplateParameterFile = $templateParametersFilePath
    Force                 = $true
}

$retryCount = 0
$retryMax = 30
$initialRetryDelay = 20
$retryDelayIncrement = 10
$finalSuccess = $false

while ($retryCount -lt $retryMax) {
    if($retryCount -gt 0) {
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

                $result = New-AzManagementGroupDeploymentStack @stackParameters -ManagementGroupId $targetManagementGroupId -Location $location
            }
            "subscription" {
                if (-not [string]::IsNullOrWhiteSpace($subscriptionId)) {
                    Select-AzSubscription -SubscriptionId $subscriptionId | Out-Null
                }

                $result = New-AzSubscriptionDeploymentStack @stackParameters -Location $location
            }
            "resourceGroup" {
                if (-not [string]::IsNullOrWhiteSpace($subscriptionId)) {
                    Select-AzSubscription -SubscriptionId $subscriptionId | Out-Null
                }

                $result = New-AzResourceGroupDeploymentStack @stackParameters -ResourceGroupName $resourceGroupName -Location $location
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
    Write-Host "Provisioning State: $($result.Properties.ProvisioningState)"

    if($result.Properties.ProvisioningState -ne "Succeeded") {
        Write-Host "Deployment stack provisioning did not succeed. Entering retry loop..." -ForegroundColor Red
        $retryCount++
    } else {
        $finalSuccess = $true
        break
    }
}

if($finalSuccess -eq $false) {
    Write-Error "Deployment stack failed after $retryMax attempts."
}

Write-Host "<---------------------------------------------------------------------------->" -ForegroundColor DarkMagenta
Write-Host "Completed deployment stack for $displayName." -ForegroundColor DarkMagenta
Write-Host "<---------------------------------------------------------------------------->" -ForegroundColor DarkMagenta
Write-Host ""
