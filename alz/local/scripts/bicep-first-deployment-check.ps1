param(
    [string]$managementGroupId
)

# Read the int-root management group name from the bicepparam file
$intRootParamFile = "templates/core/governance/mgmt-groups/int-root/main.bicepparam"
if (Test-Path $intRootParamFile) {
  $paramContent = Get-Content $intRootParamFile -Raw
  if ($paramContent -match 'managementGroupName:\s*[''"](\w+)[''"]+') {
    $intRootMgId = $matches[1]
    Write-Host "Found int-root management group name in param file: $intRootMgId"
  } else {
    Write-Warning "Could not parse managementGroupName from $intRootParamFile, using default 'alz'"
    $intRootMgId = "alz"
  }
} else {
  Write-Warning "Int-root param file not found at $intRootParamFile, using default 'alz'"
  $intRootMgId = "alz"
}

$managementGroups = Get-AzManagementGroup
$intRootMg = $managementGroups | Where-Object { $_.Name -eq $intRootMgId }

$firstDeployment = $true

if ($null -eq $intRootMg) {
  Write-Warning "Cannot find the $intRootMgId Management Group, so assuming this is the first deployment. We must skip checking some deployments since their dependent resources do not exist yet."
} else {
  Write-Host "Found the $intRootMgId Management Group, so assuming this is not the first deployment."
  $firstDeployment = $false
}

return $firstDeployment
