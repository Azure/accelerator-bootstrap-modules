param(
  [switch]$destroy,
  [string]$root_module_folder_relative_path = "${root_module_folder_relative_path}",
  [string]$remote_state_resource_group_name = "${remote_state_resource_group_name}",
  [string]$remote_state_storage_account_name = "${remote_state_storage_account_name}",
  [string]$remote_state_storage_container_name = "${remote_state_storage_container_name}",
  [switch]$auto_approve
)

# Check and Set Subscription ID
$wasSubscriptionIdSet = $false
if($null -eq $env:ARM_SUBSCRIPTION_ID -or $env:ARM_SUBSCRIPTION_ID -eq "") {
  Write-Host "Setting environment variable ARM_SUBSCRIPTION_ID"
  $subscriptionId = $(az account show --query id -o tsv)
  if($null -eq $subscriptionId -or $subscriptionId -eq "") {
      Write-Error "Subscription ID not found. Please ensure you are logged in to Azure and have selected a subscription. Use 'az account show' to check."
      return
  }
  $env:ARM_SUBSCRIPTION_ID = $subscriptionId
  $wasSubscriptionIdSet = $true
  Write-Host "Environment variable ARM_SUBSCRIPTION_ID set to $subscriptionId"
}

# Initialize the Terraform configuration
$use_remote_state = $false
if($remote_state_resource_group_name -ne "" -and $remote_state_storage_account_name -ne "" -and $remote_state_storage_container_name -ne "") {
  $use_remote_state = $true
} else {
  $use_remote_state = $false
}

$command = "terraform"
$arguments = @()
$arguments += "-chdir=$root_module_folder_relative_path"
$arguments += "init"
if($use_remote_state) {
  $arguments += "-migrate-state"
  $arguments += "-backend-config=resource_group_name=$remote_state_resource_group_name"
  $arguments += "-backend-config=storage_account_name=$remote_state_storage_account_name"
  $arguments += "-backend-config=container_name=$remote_state_storage_container_name"
  $arguments += "-backend-config=key=terraform.tfstate"
  $arguments += "-backend-config=use_azuread_auth=true"
}
Write-Host "Running: $command $arguments"
& $command $arguments

# Run the Terraform plan
$command = "terraform"
$arguments = @()
$arguments += "-chdir=$root_module_folder_relative_path"
$arguments += "plan"
if($destroy) {
  $arguments += "-destroy"
}
$arguments += "-out=tfplan"
Write-Host "Running: $command $arguments"
& $command $arguments

# Review the Terraform plan
$command = "terraform"
$arguments = @()
$arguments += "-chdir=$root_module_folder_relative_path"
$arguments += "show"
$arguments += "tfplan"
Write-Host "Running: $command $arguments"
& $command $arguments

$runType = $destroy ? "DESTROY" : "CREATE OR UPDATE"
if($auto_approve) {
  Write-Host "Auto-approving the run to $runType the resources."
} else {
  Write-Host ""
  $deployApproved = Read-Host -Prompt "Type 'yes' and hit Enter to $runType the resources."
  Write-Host ""

  if($deployApproved -ne "yes") {
    Write-Error "Deployment was not approved. Exiting..."
    exit 1
  }
}

# Apply the Terraform plan
$command = "terraform"
$arguments = @()
$arguments += "-chdir=$root_module_folder_relative_path"
$arguments += "apply"
$arguments += "tfplan"
Write-Host "Running: $command $arguments"
& $command $arguments

# Check and Unset Subscription ID
if($wasSubscriptionIdSet) {
  Write-Host "Unsetting environment variable ARM_SUBSCRIPTION_ID"
  $env:ARM_SUBSCRIPTION_ID = $null
  Write-Host "Environment variable ARM_SUBSCRIPTION_ID unset"
}
