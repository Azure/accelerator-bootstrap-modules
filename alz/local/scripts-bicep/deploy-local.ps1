[CmdletBinding()]
param()

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$rootDirectory = Split-Path -Parent $scriptRoot
$verbose = $PSBoundParameters.Verbose.IsPresent
Write-Host "Verbose: $verbose"

# Getting the variables from the parameters.json file in the root directory
& (Join-Path $scriptRoot 'bicep-get-variables.ps1') -fileName (Join-Path $rootDirectory "parameters.json")

Write-Host ""
$deployApproved = Read-Host -Prompt "Type 'yes' and hit Enter to continue with the full deployment"
Write-Host ""

if ($deployApproved -ne "yes") {
    Write-Error "Deployment was not approved. Exiting..."
    exit 1
}

%{ for script_file in script_files ~}
# Running deployment stack for ${script_file.displayName}
& (Join-Path $scriptRoot 'bicep-deploy.ps1') `
    -name "${script_file.name}" `
    -displayName "${script_file.displayName}" `
    -templateFilePath "${script_file.templateFilePath}" `
    -templateParametersFilePath "${script_file.templateParametersFilePath}" `
    -subscriptionId ${script_file.subscriptionIdVariable} `
    -resourceGroupName ${script_file.resourceGroupNameVariable} `
    -location $env:LOCATION `
    -deploymentType "${script_file.deploymentType}"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

%{ endfor ~}
