param (
    [int]$maximumRetries = 10,
    [int]$retryCount = 0,
    [int]$retryDelay = 10000,
    [string]$versionControlSystem
)

$bootstrapDirectoryPath = "./bootstrap/local/alz/$versionControlSystem"
Write-Host "Bootstrap Directory Path: $bootstrapDirectoryPath"

if(Test-Path -Path "$bootstrapDirectoryPath/override.tfvars") {
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
        Deploy-Accelerator -inputs "./inputs.json" -bootstrapModuleOverrideFolderPath "./$($env:SOURCE_CODE_FOLDER)" -autoApprove -destroy -ErrorAction Stop
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