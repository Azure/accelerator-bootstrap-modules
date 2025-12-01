module "resource_names" {
  source           = "../../modules/resource_names"
  azure_location   = var.bootstrap_location
  environment_name = var.environment_name
  service_name     = var.service_name
  postfix_number   = var.postfix_number
  resource_names   = merge(var.resource_names, local.custom_role_definitions_bicep_names, local.custom_role_definitions_terraform_names)
}

module "files" {
  source                            = "../../modules/files"
  starter_module_folder_path        = local.starter_module_folder_path
  additional_files                  = var.additional_files
  configuration_file_path           = var.configuration_file_path
  built_in_configuration_file_names = var.built_in_configuration_file_names
  additional_folders_path           = var.additional_folders_path
}

module "azure" {
  source                                               = "../../modules/azure"
  count                                                = var.create_bootstrap_resources_in_azure ? 1 : 0
  user_assigned_managed_identities                     = local.managed_identities
  federated_credentials                                = local.federated_credentials
  resource_group_identity_name                         = local.resource_names.resource_group_identity
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
  bootstrap_role_assignment_enabled                    = var.iac_type == "bicep"
  tenant_role_assignment_enabled                       = var.iac_type == "bicep" && var.tenant_role_assignment_enabled
  tenant_role_assignment_role_definition_name          = var.tenant_role_assignment_role_definition_name
}

module "file_manipulation" {
  source                           = "../../modules/file_manipulation"
  vcs_type                         = "local"
  files                            = module.files.files
  resource_names                   = local.resource_names
  iac_type                         = var.iac_type
  module_folder_path               = local.starter_module_folder_path
  bicep_config_file_path           = var.bicep_config_file_path
  starter_module_name              = var.starter_module_name
  root_module_folder_relative_path = var.root_module_folder_relative_path
  on_demand_folder_repository      = var.on_demand_folder_repository
  on_demand_folder_artifact_name   = var.on_demand_folder_artifact_name
  pipeline_target_folder_name      = local.script_target_folder_name
  bicep_parameters_file_path       = var.bicep_parameters_file_path
  subscription_ids                 = var.subscription_ids
  root_parent_management_group_id  = var.root_parent_management_group_id
  pipeline_files_directory_path    = local.script_source_folder_path
}

resource "local_file" "alz" {
  for_each = module.file_manipulation.repository_files
  content  = each.value.content
  filename = "${local.target_directory}/${each.key}"
}

resource "local_file" "command" {
  count    = var.iac_type == "terraform" ? 1 : 0
  content  = local.command_final
  filename = "${local.target_directory}/scripts/deploy-local.ps1"
}
