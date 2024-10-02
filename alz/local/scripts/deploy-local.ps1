[CmdletBinding()]
param()

$verbose = $PSBoundParameters.Verbose.IsPresent
Write-Host "Verbose: $verbose"

# Getting the variables from the parameters.json file
./scripts/bicep-get-variables.ps1 -fileName "parameters.json"

# Checking if this is the first deployment
$isFirstDeployment = ./scripts/bicep-first-deployment-check.ps1 -managementGroupId $env:MANAGEMENT_GROUP_ID

%{ for on_demand_folder in on_demand_folders ~}
# Downloading the on demand folder for ${on_demand_folder.target}
./scripts/bicep-on-demand-folder.ps1 `
    -repository "${on_demand_folder_repository}" `
    -releaseArtifactName "${on_demand_folder_artifact_name}" `
    -releaseVersion $env:RELEASE_VERSION `
    -sourcePath "${on_demand_folder.source}" `
    -targetPath "${on_demand_folder.target}" `
%{ endfor ~}

%{ for script_file in script_files ~}
# Running What If for ${script_file.displayName}
./scripts/bicep-deploy.ps1 `
    -displayName "${script_file.displayName}" `
    -templateFilePath "${script_file.templateFilePath}" `
    -templateParametersFilePath "${script_file.templateParametersFilePath}" `
    -managementGroupId ${script_file.managementGroupIdVariable} `
    -subscriptionId ${script_file.subscriptionIdVariable} `
    -resourceGroupName ${script_file.resourceGroupNameVariable} `
    -location $env:LOCATION `
    -deploymentType "${script_file.deploymentType}" `
    -firstRunWhatIf ${script_file.firstRunWhatIf} `
    -firstDeployment $isFirstDeployment `
    -whatIf

%{ endfor ~}

Write-Host ""
$deployApproved = Read-Host -Prompt "Type 'yes' and hit Enter to continue with the full deployment"
Write-Host ""

if($deployApproved -ne "yes") {
    Write-Error "Deployment was not approved. Exiting..."
    exit 1
}

%{ for script_file in script_files ~}
# Running Deployment for ${script_file.displayName}
./scripts/bicep-deploy.ps1 `
    -displayName "${script_file.displayName}" `
    -templateFilePath "${script_file.templateFilePath}" `
    -templateParametersFilePath "${script_file.templateParametersFilePath}" `
    -managementGroupId ${script_file.managementGroupIdVariable} `
    -subscriptionId ${script_file.subscriptionIdVariable} `
    -resourceGroupName ${script_file.resourceGroupNameVariable} `
    -location $env:LOCATION `
    -deploymentType "${script_file.deploymentType}" `
    -firstRunWhatIf ${script_file.firstRunWhatIf} `
    -firstDeployment $isFirstDeployment `

%{ endfor ~}
