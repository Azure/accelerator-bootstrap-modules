param (
    [string]$ModuleUrl = "https://github.com/Azure/ALZ-PowerShell-Module",
    [string]$ModuleBranch = "main"
)

git clone -b $ModuleBranch $ModuleUrl ./accelerator-powershell-module

./accelerator-powershell-module/actions_bootstrap.ps1
Invoke-Build -File ./accelerator-powershell-module/src/ALZ.build.ps1
