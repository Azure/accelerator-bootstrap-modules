param(
    [string]$managementGroupId
)

$managementGroups = Get-AzManagementGroup
$managementGroup = $managementGroups | Where-Object { $_.Name -eq $managementGroupId }

$firstDeployment = $true

if($null -eq $managementGroup) {
  Write-Warning "Cannot find the $managementGroupId Management Group, so assuming this is the first deployment. We must skip checking some deployments since their dependent resources do not exist yet."
} else {
  Write-Host "Found the $managementGroupId Management Group, so assuming this is not the first deployment."
  $firstDeployment = $false
}

return $firstDeployment