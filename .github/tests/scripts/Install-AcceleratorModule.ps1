param (
    [string]$ModuleUrl = "https://github.com/Azure/ALZ-PowerShell-Module",
    [string]$ModuleBranch = "main"
)

$targetDirectory = "./accelerator-powershell-module"

if(!(Test-Path $targetDirectory)) {
    git clone -b $ModuleBranch $ModuleUrl $targetDirectory
}

./accelerator-powershell-module/actions_bootstrap_for_e2e_tests.ps1  | Out-String | Write-Verbose
Invoke-Build -File ./accelerator-powershell-module/src/ALZ.build.ps1 BuildAndInstallOnly | Out-String | Write-Verbose
