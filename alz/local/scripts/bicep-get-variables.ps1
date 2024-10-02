param(
    [string]$fileName="parameters.json"
)

Write-Host "Getting variables from $fileName"
$json = Get-Content -Path $fileName | ConvertFrom-Json

foreach ($key in $json.PSObject.Properties) {
  $envVarName = $key.Name
  $envVarValue = $key.Value
  [Environment]::SetEnvironmentVariable($envVarName, $envVarValue)
  Write-Output "Set $envVarName to $envVarValue"
}