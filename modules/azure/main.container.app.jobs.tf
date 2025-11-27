module "container_app_jobs" {
  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version = "~> 0.5"

  count = var.use_self_hosted_agents && var.use_container_app_jobs ? 1 : 0

  # Required inputs
  location                            = var.azure_location
  postfix                             = random_string.container_app_postfix[0].result
  version_control_system_organization = var.agent_organization_url
  version_control_system_type         = "azuredevops"

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
  container_registry_creation_enabled = false
  custom_container_registry_login_server = azurerm_container_registry.alz[0].login_server
  
  # Container registry private endpoint subnet (BYO mode)
  container_registry_private_endpoint_subnet_id = azurerm_subnet.private_endpoints[0].id
  
  # Container registry DNS zone (BYO mode - let module create)
  container_registry_private_dns_zone_creation_enabled = true

  # User-assigned managed identity (BYO mode)
  user_assigned_managed_identity_creation_enabled = false
  user_assigned_managed_identity_id               = var.managed_identity_ids["agent"]
  user_assigned_managed_identity_client_id        = var.managed_identity_client_ids["agent"]
  user_assigned_managed_identity_principal_id     = var.managed_identity_principal_ids["agent"]

  # Container App Job configuration
  container_app_container_cpu            = var.agent_container_cpu
  container_app_container_memory         = var.agent_container_memory
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

# Random string for postfix (AVM module requires max 20 chars)
resource "random_string" "container_app_postfix" {
  count   = var.use_self_hosted_agents && var.use_container_app_jobs ? 1 : 0
  length  = 6
  special = false
  upper   = false
  numeric = true
}
