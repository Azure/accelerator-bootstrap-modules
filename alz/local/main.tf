module "resource_names" {
  source           = "../../modules/resource_names"
  azure_location   = var.bootstrap_location
  environment_name = var.environment_name
  service_name     = var.service_name
  postfix_number   = var.postfix_number
  resource_names   = merge(var.resource_names, local.custom_role_definitions_bicep_names, local.custom_role_definitions_terraform_names)
}

module "architecture_definition" {
  count                                                     = local.has_architecture_definition ? 1 : 0
  source                                                    = "../../modules/template_architecture_definition"
  starter_module_folder_path                                = local.starter_root_module_folder_path
  architecture_definition_name                              = local.architecture_definition_name
  architecture_definition_template_path                     = var.architecture_definition_template_path
  architecture_definition_override_path                     = var.architecture_definition_override_path
  apply_alz_archetypes_via_architecture_definition_template = var.apply_alz_archetypes_via_architecture_definition_template
}

resource "local_file" "architecture_definition_file" {
  count    = local.has_architecture_definition ? 1 : 0
  content  = module.architecture_definition[0].architecture_definition_json
  filename = local.architecture_definition_file_destination
}

module "files" {
  source                            = "../../modules/files"
  starter_module_folder_path        = local.starter_module_folder_path
  additional_files                  = var.additional_files
  configuration_file_path           = var.configuration_file_path
  built_in_configuration_file_names = var.built_in_configuration_file_names
  additional_folders_path           = var.additional_folders_path
}

# ========================================
# IDENTITY MANAGEMENT (Optional for local deployment)
# ========================================
# Create bootstrap identities only if deploying Azure resources

module "identities" {
  count                 = var.create_bootstrap_resources_in_azure ? 1 : 0
  source                = "../../modules/identities"
  resource_group_name   = local.resource_names.resource_group_identity
  location              = var.bootstrap_location
  managed_identities    = local.managed_identities
  federated_credentials = var.federated_credentials
  tags                  = var.tags
}

module "azure" {
  source                                               = "../../modules/azure"
  count                                                = var.create_bootstrap_resources_in_azure ? 1 : 0
  managed_identity_ids                                 = module.identities[0].managed_identity_ids
  managed_identity_client_ids                          = module.identities[0].managed_identity_client_ids
  managed_identity_principal_ids                       = module.identities[0].managed_identity_principal_ids
  resource_group_identity_name                         = module.identities[0].resource_group_name
  resource_group_state_name                            = local.resource_names.resource_group_state
  create_storage_account                               = var.iac_type == local.iac_terraform
  storage_account_name                                 = local.resource_names.storage_account
  storage_container_name                               = local.resource_names.storage_container
  azure_location                                       = var.bootstrap_location
  target_subscriptions                                 = local.target_subscriptions
  root_parent_management_group_id                      = local.root_parent_management_group_id
  storage_account_replication_type                     = var.storage_account_replication_type
  use_self_hosted_agents                               = false
  use_private_networking                               = false
  custom_role_definitions                              = var.iac_type == "terraform" ? local.custom_role_definitions_terraform : local.custom_role_definitions_bicep
  role_assignments                                     = var.iac_type == "terraform" ? var.role_assignments_terraform : var.role_assignments_bicep
  additional_role_assignment_principal_ids             = var.grant_permissions_to_current_user ? { current_user = data.azurerm_client_config.current.object_id } : {}
  storage_account_blob_soft_delete_enabled             = var.storage_account_blob_soft_delete_enabled
  storage_account_blob_soft_delete_retention_days      = var.storage_account_blob_soft_delete_retention_days
  storage_account_blob_versioning_enabled              = var.storage_account_blob_versioning_enabled
  storage_account_container_soft_delete_enabled        = var.storage_account_container_soft_delete_enabled
  storage_account_container_soft_delete_retention_days = var.storage_account_container_soft_delete_retention_days
}

resource "local_file" "alz" {
  for_each = local.final_module_files
  content  = each.value.content
  filename = "${local.target_directory}/${each.key}"
}

resource "local_file" "command" {
  count    = var.iac_type == "terraform" ? 1 : 0
  content  = local.command_final
  filename = "${local.target_directory}/scripts/deploy-local.ps1"
}

moved {
  from = module.azure[0].azurerm_resource_group.identity
  to   = module.identities[0].azurerm_resource_group.identity
}

moved {
  from = module.azure[0].azurerm_user_assigned_identity.alz
  to   = module.identities[0].azurerm_user_assigned_identity.identities
}

moved {
  from = module.azure[0].azurerm_federated_identity_credential.alz
  to   = module.identities[0].azurerm_federated_identity_credential.credentials
}
