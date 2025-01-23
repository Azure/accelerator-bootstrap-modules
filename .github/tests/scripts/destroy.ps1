param (
    [int]$maximumRetries = 10,
    [int]$retryCount = 0,
    [int]$retryDelay = 10000,
    [string]$versionControlSystem
)

$bootstrapDirectoryPath = "$($env:TARGET_FOLDER)/bootstrap/local/alz/$versionControlSystem"
Write-Host "Bootstrap Directory Path: $bootstrapDirectoryPath"

if(Test-Path -Path "$bootstrapDirectoryPath/terraform.tfvars.json") {
    Write-Host "Bootstrap tfvars Exists"
} else {
    Write-Host "Bootstrap tfvars does not exist, so there is nothing to clean up. Exiting now."
    exit 0
}

$success = $false

do {
    $retryCount++
    try {
        $myIp = Invoke-RestMethod -Uri http://ipinfo.io/json | Select-Object -ExpandProperty ip
        Write-Host "Runner IP Address: $myIp"

        Write-Host "Running Terraform Destroy"
        $starterModuleOverrideFolderPath = $env:STARTER_MODULE_FOLDER
        if($infrastructureAsCode -eq "terraform") { 
          $starterModuleOverrideFolderPath = "$starterModuleOverrideFolderPath/templates"
        }
        Deploy-Accelerator -output "$($env:TARGET_FOLDER)" -inputs "./inputs.json" -bootstrapModuleOverrideFolderPath "$($env:BOOTSTRAP_MODULE_FOLDER)" -starterModuleOverrideFolderPath $starterModuleOverrideFolderPath -starterRelease "$($env.ALZ_ON_DEMAND_FOLDER_RELEASE_TAG)" -autoApprove -skipAlzModuleVersionRequirementsCheck -destroy -ErrorAction Stop
        if ($LastExitCode -eq 0) {
            $success = $true
        } else {
            throw "Failed to destroy the bootstrap environment."
        }
    } catch {
        Write-Host "Failed to destroy the bootstrap environment."
        Start-Sleep -Milliseconds $retryDelay
    }
} while ($success -eq $false -and $retryCount -lt $maximumRetries)

if ($success -eq $false) {
    throw "Failed to destroy the bootstrap environment after $maximumRetries attempts."
}