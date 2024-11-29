resource "azurerm_container_group" "alz" {
  for_each            = var.use_self_hosted_agents ? var.agent_container_instances : {}
  name                = each.value.container_instance_name
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.agents[0].name
  ip_address_type     = var.use_private_networking ? "Private" : "None"
  os_type             = "Linux"
  subnet_ids          = var.use_private_networking ? [azurerm_subnet.container_instances[0].id] : []
  zones               = length(local.bootstrap_location_zones) == 0 ? null : each.value.zones

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_instances[0].id]
  }

  image_registry_credential {
    server                    = azurerm_container_registry.alz[0].login_server
    user_assigned_identity_id = azurerm_user_assigned_identity.container_instances[0].id
  }

  container {
    name  = each.value.container_instance_name
    image = "${azurerm_container_registry.alz[0].login_server}/${var.container_registry_image_name}:${var.container_registry_image_tag}"


    cpu          = each.value.cpu
    memory       = each.value.memory
    cpu_limit    = each.value.cpu_max
    memory_limit = each.value.memory_max

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = merge({
      (var.agent_organization_environment_variable) = var.agent_organization_url
      (var.agent_name_environment_variable)         = each.value.agent_name
      }, var.use_agent_pool_environment_variable ? {
      (var.agent_pool_environment_variable) = var.agent_pool_name
    } : {})

    secure_environment_variables = {
      (var.agent_token_environment_variable) = var.agent_token
    }
  }

  depends_on = [azurerm_container_registry_task_schedule_run_now.alz]
}

resource "azurerm_user_assigned_identity" "container_instances" {
  count               = var.use_self_hosted_agents ? 1 : 0
  location            = var.azure_location
  name                = var.agent_container_instance_managed_identity_name
  resource_group_name = azurerm_resource_group.agents[0].name
}
