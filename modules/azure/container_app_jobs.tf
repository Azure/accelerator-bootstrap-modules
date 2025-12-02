module "container_app_jobs" {
  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version = "~> 0.5"

  count = var.use_self_hosted_agents && var.use_container_app_jobs ? 1 : 0

  # Required inputs
  location                            = var.azure_location
  postfix                             = "${var.service_name}-${var.environment_name}"
  version_control_system_organization = var.agent_organization_url
  version_control_system_type         = "azuredevops"

  # Override default naming to follow bootstrap naming convention
  container_app_environment_name                   = var.container_app_environment_name
  container_app_job_name                           = var.container_app_job_name
  container_app_placeholder_job_name               = var.container_app_job_placeholder_name
  container_app_infrastructure_resource_group_name = var.container_app_infrastructure_resource_group_name

  # Compute type
  compute_types = ["azure_container_app"]

  # Resource group (BYO mode)
  resource_group_creation_enabled = false
  resource_group_name             = azurerm_resource_group.agents[0].name

  # Virtual network (BYO mode)
  virtual_network_creation_enabled = false
  virtual_network_name             = azurerm_virtual_network.alz[0].name
  virtual_network_address_space    = var.virtual_network_address_space
  virtual_network_id               = azurerm_virtual_network.alz[0].id
  container_app_subnet_id          = azurerm_subnet.container_apps[0].id

  # Container registry (BYO mode)
  container_registry_creation_enabled                  = false
  custom_container_registry_login_server               = azurerm_container_registry.alz[0].login_server
  container_registry_private_endpoint_subnet_id        = azurerm_subnet.private_endpoints[0].id
  container_registry_dns_zone_id                       = azurerm_private_dns_zone.alz["container_registry"].id
  container_registry_private_dns_zone_creation_enabled = false

  # Custom container image (use our pre-built image)
  use_default_container_image = false
  custom_container_registry_images = {
    container_app = {
      task_name            = "image-build-task"
      dockerfile_path      = var.container_registry_dockerfile_name
      context_path         = var.container_registry_dockerfile_repository_folder_url
      context_access_token = "a"
      image_names          = ["${var.container_registry_image_name}:${var.container_registry_image_tag}"]
    }
  }

  # User-assigned managed identity (BYO mode)
  user_assigned_managed_identity_creation_enabled = false
  user_assigned_managed_identity_id               = var.managed_identity_ids["agent"]
  user_assigned_managed_identity_client_id        = var.managed_identity_client_ids["agent"]
  user_assigned_managed_identity_principal_id     = var.managed_identity_principal_ids["agent"]

  # Container App Job configuration
  container_app_container_cpu            = var.agent_container_cpu
  container_app_container_memory         = "${var.agent_container_memory}Gi"
  container_app_max_execution_count      = 10
  container_app_min_execution_count      = 0
  container_app_polling_interval_seconds = 30

  # Version control system configuration
  version_control_system_authentication_method = "uami"
  version_control_system_personal_access_token = null
  version_control_system_pool_name             = var.agent_pool_name

  # Private networking
  use_private_networking = true

  depends_on = [
    azurerm_role_assignment.container_registry_pull_for_agent,
    azurerm_role_assignment.container_registry_push_for_agent
  ]
}
