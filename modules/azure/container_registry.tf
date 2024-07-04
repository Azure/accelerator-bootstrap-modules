resource "azurerm_container_registry" "alz" {
  count                         = var.use_self_hosted_agents ? 1 : 0
  name                          = var.container_registry_name
  resource_group_name           = azurerm_resource_group.agents[0].name
  location                      = var.azure_location
  sku                           = var.use_private_networking ? "Premium" : "Basic"
  public_network_access_enabled = !var.use_private_networking
  zone_redundancy_enabled       = var.use_private_networking
  network_rule_bypass_option    = var.use_private_networking ? "AzureServices" : "None"
}

resource "azurerm_container_registry_task" "alz" {
  count                 = var.use_self_hosted_agents ? 1 : 0
  name                  = "image-build-task"
  container_registry_id = azurerm_container_registry.alz[0].id
  platform {
    os = "Linux"
  }
  docker_step {
    dockerfile_path      = var.container_registry_dockerfile_name
    context_path         = var.container_registry_dockerfile_repository_folder_url
    context_access_token = "a" # This is a dummy value becuase the context_access_token should not be required in the provider
    image_names          = ["${var.container_registry_image_name}:${var.container_registry_image_tag}"]
  }
  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_registry[0].id]
  }
}

resource "azurerm_container_registry_task_schedule_run_now" "alz" {
  count                      = var.use_self_hosted_agents ? 1 : 0
  container_registry_task_id = azurerm_container_registry_task.alz[0].id
  lifecycle {
    replace_triggered_by = [azurerm_container_registry_task.alz]
  }
}

resource "azurerm_role_assignment" "container_registry_pull" {
  count                = var.use_self_hosted_agents ? 1 : 0
  scope                = azurerm_container_registry.alz[0].id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.container_instances[0].principal_id
}

resource "azurerm_user_assigned_identity" "container_registry" {
  count               = var.use_self_hosted_agents ? 1 : 0
  location            = var.azure_location
  name                = var.container_registry_managed_identity_name
  resource_group_name = azurerm_resource_group.agents[0].name
}

resource "azurerm_role_assignment" "container_registry_push" {
  count                = var.use_self_hosted_agents ? 1 : 0
  scope                = azurerm_container_registry.alz[0].id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.container_registry[0].principal_id
}
