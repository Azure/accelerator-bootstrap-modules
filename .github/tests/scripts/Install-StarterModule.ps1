param (
    [string]$ModuleUrl = "",
    [string]$ModuleBranch = "main",
    [string]$ModulePath = "./accelerator-starter-module"
)

if($null -eq $ModuleBranch -or $ModuleBranch -eq "") {
    $ModuleBranch = "main"
}

if(!(Test-Path $ModulePath)) {
    git clone -b $ModuleBranch $ModuleUrl $ModulePath
}
