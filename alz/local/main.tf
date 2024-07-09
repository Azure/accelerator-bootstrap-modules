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
  built_in_configurartion_file_name = var.built_in_configurartion_file_name
}

module "azure" {
  source                           = "../../modules/azure"
  count                            = var.create_bootstrap_resources_in_azure ? 1 : 0
  user_assigned_managed_identities = local.managed_identities
  federated_credentials            = local.federated_credentials
  resource_group_identity_name     = local.resource_names.resource_group_identity
  resource_group_state_name        = local.resource_names.resource_group_state
  create_storage_account           = var.iac_type == local.iac_terraform
  storage_account_name             = local.resource_names.storage_account
  storage_container_name           = local.resource_names.storage_container
  azure_location                   = var.bootstrap_location
  target_subscriptions             = local.target_subscriptions
  root_parent_management_group_id  = local.root_parent_management_group_id
  storage_account_replication_type = var.storage_account_replication_type
  use_self_hosted_agents           = false
  use_private_networking           = false
  custom_role_definitions          = var.iac_type == "terraform" ? local.custom_role_definitions_terraform : local.custom_role_definitions_bicep
  role_assignments                 = var.iac_type == "terraform" ? var.role_assignments_terraform : var.role_assignments_bicep
}

resource "local_file" "alz" {
  for_each = local.module_files
  content  = each.value.content
  filename = "${local.target_directory}/${each.key}"
}
