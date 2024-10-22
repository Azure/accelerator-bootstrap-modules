locals {
  command_with_azure_resources = <<COMMAND
# Initialize the Terraform configuration
terraform init `
  -chdir="${var.root_module_folder_relative_path}" `
  -backend-config="resource_group_name=${local.resource_names.resource_group_state}" `
  -backend-config="storage_account_name=${local.resource_names.storage_account}" `
  -backend-config="container_name=${local.resource_names.storage_container}" `
  -backend-config="key=terraform.tfstate" `
  -backend-config="use_azuread_auth=true"

# Run the Terraform plan
terraform plan -out=tfplan

# Review the Terraform plan
terraform show tfplan

Write-Host ""
$deployApproved = Read-Host -Prompt "Type 'yes' and hit Enter to continue with the full deployment"
Write-Host ""

if($deployApproved -ne "yes") {
  Write-Error "Deployment was not approved. Exiting..."
  exit 1
}

# Apply the Terraform plan
terraform apply tfplan

COMMAND 

  command_without_azure_resources = <<COMMAND
# Initialize the Terraform configuration
terraform init

# Run the Terraform plan
terraform plan -out=tfplan

# Review the Terraform plan
terraform show tfplan

Write-Host ""
$deployApproved = Read-Host -Prompt "Type 'yes' and hit Enter to continue with the full deployment"
Write-Host ""

if($deployApproved -ne "yes") {
  Write-Error "Deployment was not approved. Exiting..."
  exit 1
}

# Apply the Terraform plan
terraform apply tfplan

COMMAND
}
