locals {
  command_base = <<COMMAND
# Check and Set Subscription ID
if($null -eq $env:ARM_SUBSCRIPTION_ID -or $env:ARM_SUBSCRIPTION_ID -eq "") {
    Write-Verbose "Setting environment variable ARM_SUBSCRIPTION_ID"
    $subscriptionId = $(az account show --query id -o tsv)
    if($null -eq $subscriptionId -or $subscriptionId -eq "") {
        Write-Error "Subscription ID not found. Please ensure you are logged in to Azure and have selected a subscription. Use 'az account show' to check."
        return
    }
    $env:ARM_SUBSCRIPTION_ID = $subscriptionId
    Write-Verbose "Environment variable ARM_SUBSCRIPTION_ID set to $subscriptionId"
}

# Run the Terraform plan
terraform `
  -chdir="${var.root_module_folder_relative_path}" `
  plan `
  -out=tfplan

# Review the Terraform plan
terraform `
  -chdir="${var.root_module_folder_relative_path}" `
  show `
  tfplan

Write-Host ""
$deployApproved = Read-Host -Prompt "Type 'yes' and hit Enter to continue with the full deployment"
Write-Host ""

if($deployApproved -ne "yes") {
  Write-Error "Deployment was not approved. Exiting..."
  exit 1
}

# Apply the Terraform plan
terraform `
  -chdir="${var.root_module_folder_relative_path}" `
  apply `
  tfplan
COMMAND 

  command_init_without_azure_resources = <<COMMAND
# Initialize the Terraform configuration
terraform `
  -chdir="${var.root_module_folder_relative_path}" `
  init

COMMAND

  command_init_with_azure_resources = <<COMMAND
# Initialize the Terraform configuration
terraform `
  -chdir="${var.root_module_folder_relative_path}" `
  init `
  -backend-config="resource_group_name=${local.resource_names.resource_group_state}" `
  -backend-config="storage_account_name=${local.resource_names.storage_account}" `
  -backend-config="container_name=${local.resource_names.storage_container}" `
  -backend-config="key=terraform.tfstate" `
  -backend-config="use_azuread_auth=true"

COMMAND

  command_without_azure_resources = "${local.command_init_without_azure_resources}${local.command_base}"
  command_with_azure_resources    = "${local.command_init_with_azure_resources}${local.command_base}"
}
