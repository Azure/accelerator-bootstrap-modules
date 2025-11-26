param(
    [string]$fileName="parameters.json"
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

# If fileName is an absolute path, use it directly; otherwise join with scriptRoot
if ([System.IO.Path]::IsPathRooted($fileName)) {
  $parametersPath = $fileName
} else {
  $parametersPath = Join-Path $scriptRoot $fileName
}

Write-Host "Getting variables from $parametersPath"
$json = Get-Content -Path $parametersPath | ConvertFrom-Json

foreach ($key in $json.PSObject.Properties) {
  $envVarName = $key.Name
  $envVarValue = $key.Value
  [Environment]::SetEnvironmentVariable($envVarName, $envVarValue, "Process")
  Write-Output "Set $envVarName to $envVarValue"
}
