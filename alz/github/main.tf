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

module "files" {
  source                            = "../../modules/files"
  starter_module_folder_path        = local.starter_module_folder_path
  additional_files                  = var.additional_files
  configuration_file_path           = var.configuration_file_path
  built_in_configuration_file_names = var.built_in_configuration_file_names
  additional_folders_path           = var.additional_folders_path
}

module "azure" {
  source                                                    = "../../modules/azure"
  user_assigned_managed_identities                          = local.managed_identities
  federated_credentials                                     = local.federated_credentials
  resource_group_identity_name                              = local.resource_names.resource_group_identity
  resource_group_state_name                                 = local.resource_names.resource_group_state
  resource_group_agents_name                                = local.resource_names.resource_group_agents
  resource_group_network_name                               = local.resource_names.resource_group_network
  create_storage_account                                    = var.iac_type == local.iac_terraform
  storage_account_name                                      = local.resource_names.storage_account
  storage_container_name                                    = local.resource_names.storage_container
  azure_location                                            = var.bootstrap_location
  target_subscriptions                                      = local.target_subscriptions
  root_parent_management_group_id                           = local.root_parent_management_group_id
  agent_container_instances                                 = local.runner_container_instances
  agent_container_instance_managed_identity_name            = local.resource_names.container_instance_managed_identity
  agent_organization_url                                    = local.runner_organization_repository_url
  agent_token                                               = var.github_runners_personal_access_token
  agent_organization_environment_variable                   = var.runner_organization_environment_variable
  agent_pool_name                                           = local.resource_names.version_control_system_runner_group
  agent_pool_environment_variable                           = var.runner_group_environment_variable
  agent_name_environment_variable                           = var.runner_name_environment_variable
  use_agent_pool_environment_variable                       = local.use_runner_group
  agent_token_environment_variable                          = var.runner_token_environment_variable
  virtual_network_name                                      = local.resource_names.virtual_network
  virtual_network_subnet_name_container_instances           = local.resource_names.subnet_container_instances
  virtual_network_subnet_name_private_endpoints             = local.resource_names.subnet_private_endpoints
  storage_account_private_endpoint_name                     = local.resource_names.storage_account_private_endpoint
  use_private_networking                                    = local.use_private_networking
  allow_storage_access_from_my_ip                           = local.allow_storage_access_from_my_ip
  virtual_network_address_space                             = var.virtual_network_address_space
  virtual_network_subnet_address_prefix_container_instances = var.virtual_network_subnet_address_prefix_container_instances
  virtual_network_subnet_address_prefix_private_endpoints   = var.virtual_network_subnet_address_prefix_private_endpoints
  storage_account_replication_type                          = var.storage_account_replication_type
  public_ip_name                                            = local.resource_names.public_ip
  nat_gateway_name                                          = local.resource_names.nat_gateway
  use_self_hosted_agents                                    = var.use_self_hosted_runners
  container_registry_name                                   = local.resource_names.container_registry
  container_registry_private_endpoint_name                  = local.resource_names.container_registry_private_endpoint
  container_registry_image_name                             = local.resource_names.container_image_name
  container_registry_image_tag                              = var.runner_container_image_tag
  container_registry_dockerfile_name                        = var.runner_container_image_dockerfile
  container_registry_dockerfile_repository_folder_url       = local.runner_container_instance_dockerfile_url
  custom_role_definitions                                   = var.iac_type == "terraform" ? local.custom_role_definitions_terraform : local.custom_role_definitions_bicep
  role_assignments                                          = var.iac_type == "terraform" ? var.role_assignments_terraform : var.role_assignments_bicep
}

module "github" {
  source                                       = "../../modules/github"
  domain_name                                  = var.github_organization_domain_name
  organization_name                            = var.github_organization_name
  environments                                 = local.environments
  repository_name                              = local.resource_names.version_control_system_repository
  use_template_repository                      = var.use_separate_repository_for_templates
  repository_name_templates                    = local.resource_names.version_control_system_repository_templates
  repository_files                             = local.repository_files
  template_repository_files                    = local.template_repository_files
  workflows                                    = local.workflows
  managed_identity_client_ids                  = module.azure.user_assigned_managed_identity_client_ids
  azure_tenant_id                              = data.azurerm_client_config.current.tenant_id
  azure_subscription_id                        = data.azurerm_client_config.current.subscription_id
  backend_azure_resource_group_name            = local.resource_names.resource_group_state
  backend_azure_storage_account_name           = local.resource_names.storage_account
  backend_azure_storage_account_container_name = local.resource_names.storage_container
  approvers                                    = var.apply_approvers
  create_team                                  = var.apply_approval_team_creation_enabled
  existing_team_name                           = var.apply_approval_existing_team_name
  team_name                                    = local.resource_names.version_control_system_team
  runner_group_name                            = local.resource_names.version_control_system_runner_group
  use_runner_group                             = local.use_runner_group
  default_runner_group_name                    = var.default_runner_group_name
  use_self_hosted_runners                      = var.use_self_hosted_runners
  create_branch_policies                       = var.create_branch_policies
}
