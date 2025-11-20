param(
    [string]$fileName="parameters.json"
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$parametersPath = Join-Path $scriptRoot $fileName

Write-Host "Getting variables from $parametersPath"
$json = Get-Content -Path $parametersPath | ConvertFrom-Json

foreach ($key in $json.PSObject.Properties) {
  $envVarName = $key.Name
  $envVarValue = $key.Value
  [Environment]::SetEnvironmentVariable($envVarName, $envVarValue, "Process")
  Write-Output "Set $envVarName to $envVarValue"
}
