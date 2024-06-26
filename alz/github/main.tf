module "resource_names" {
  source           = "../../modules/resource_names"
  azure_location   = var.bootstrap_location
  environment_name = var.environment_name
  service_name     = var.service_name
  postfix_number   = var.postfix_number
  resource_names   = var.resource_names
}

module "files" {
  source                            = "../../modules/files"
  starter_module_folder_path        = local.starter_module_folder_path
  additional_files                  = var.additional_files
  configuration_file_path           = var.configuration_file_path
  built_in_configurartion_file_name = var.built_in_configurartion_file_name
}

module "azure" {
  source                                                    = "../../modules/azure"
  user_assigned_managed_identities                          = local.managed_identities
  federated_credentials                                     = local.federated_credentials
  resource_group_identity_name                              = local.resource_names.resource_group_identity
  resource_group_state_name                                 = local.resource_names.resource_group_state
  resource_group_agents_name                                = local.resource_names.resource_group_agents
  resource_group_network_name                               = local.resource_names.resource_group_network
  storage_account_name                                      = local.resource_names.storage_account
  storage_container_name                                    = local.resource_names.storage_container
  azure_location                                            = var.bootstrap_location
  target_subscriptions                                      = local.target_subscriptions
  root_parent_management_group_id                           = local.root_parent_management_group_id
  agent_container_instances                                 = local.runner_container_instances
  agent_container_instance_image                            = var.runner_container_image
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
  virtual_network_subnet_name_storage                       = local.resource_names.subnet_storage
  private_endpoint_name                                     = local.resource_names.private_endpoint
  use_private_networking                                    = var.use_private_networking
  allow_storage_access_from_my_ip                           = var.allow_storage_access_from_my_ip
  virtual_network_address_space                             = var.virtual_network_address_space
  virtual_network_subnet_address_prefix_container_instances = var.virtual_network_subnet_address_prefix_container_instances
  virtual_network_subnet_address_prefix_storage             = var.virtual_network_subnet_address_prefix_storage
  storage_account_replication_type                          = var.storage_account_replication_type
  public_ip_name                                            = local.resource_names.public_ip
  nat_gateway_name                                          = local.resource_names.nat_gateway
}

module "github" {
  source                                       = "../../modules/github"
  organization_name                            = var.github_organization_name
  environments                                 = local.environments
  repository_name                              = local.resource_names.version_control_system_repository
  use_template_repository                      = var.use_separate_repository_for_workflow_templates
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
  team_name                                    = local.resource_names.version_control_system_team
  runner_group_name                            = local.resource_names.version_control_system_runner_group
  use_runner_group                             = local.use_runner_group
  default_runner_group_name                    = var.default_runner_group_name
  use_self_hosted_runners                      = var.use_self_hosted_runners
}
