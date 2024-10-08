module "resource_names" {
  source           = "../../modules/resource_names"
  azure_location   = var.bootstrap_location
  environment_name = var.environment_name
  service_name     = var.service_name
  postfix_number   = var.postfix_number
  resource_names   = merge(var.resource_names, local.custom_role_definitions_bicep_names, local.custom_role_definitions_terraform_names)
}

module "architecture_definition" {
  count                        = local.has_architecture_definition ? 1 : 0
  source                       = "../../modules/template_architecture_definition"
  starter_module_folder_path   = local.starter_module_folder_path
  architecture_definition_name = local.architecture_definition_name
}

resource "local_file" "architecture_definition_file" {
  count    = local.has_architecture_definition ? 1 : 0
  content  = module.architecture_definition[0].architecture_definition_json
  filename = local.architecture_definition_file_destination
}

module "files" {
  source                             = "../../modules/files"
  starter_module_folder_path         = local.starter_module_folder_path
  additional_files                   = var.additional_files
  configuration_file_path            = var.configuration_file_path
  built_in_configurartion_file_names = var.built_in_configurartion_file_names
  additional_folders_path            = var.additional_folders_path
}

module "azure" {
  source                                   = "../../modules/azure"
  count                                    = var.create_bootstrap_resources_in_azure ? 1 : 0
  user_assigned_managed_identities         = local.managed_identities
  federated_credentials                    = local.federated_credentials
  resource_group_identity_name             = local.resource_names.resource_group_identity
  resource_group_state_name                = local.resource_names.resource_group_state
  create_storage_account                   = var.iac_type == local.iac_terraform
  storage_account_name                     = local.resource_names.storage_account
  storage_container_name                   = local.resource_names.storage_container
  azure_location                           = var.bootstrap_location
  target_subscriptions                     = local.target_subscriptions
  root_parent_management_group_id          = local.root_parent_management_group_id
  storage_account_replication_type         = var.storage_account_replication_type
  use_self_hosted_agents                   = false
  use_private_networking                   = false
  custom_role_definitions                  = var.iac_type == "terraform" ? local.custom_role_definitions_terraform : local.custom_role_definitions_bicep
  role_assignments                         = var.iac_type == "terraform" ? var.role_assignments_terraform : var.role_assignments_bicep
  additional_role_assignment_principal_ids = var.grant_permissions_to_current_user ? { current_user = data.azurerm_client_config.current.object_id } : {}
}

resource "local_file" "alz" {
  for_each = local.final_module_files
  content  = each.value.content
  filename = "${local.target_directory}/${each.key}"
}

locals {
  command_with_azure_resources = <<COMMAND
# Initialize the Terraform configuration
terraform init `
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

resource "local_file" "command" {
  count    = var.iac_type == "terraform" ? 1 : 0
  content  = var.create_bootstrap_resources_in_azure ? local.command_with_azure_resources : local.command_without_azure_resources
  filename = "${local.target_directory}/scripts/deploy-local.ps1"
}
