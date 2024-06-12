resource "azurerm_resource_group" "state" {
  count    = var.create_storage_account ? 1 : 0
  name     = var.resource_group_state_name
  location = var.azure_location
}

resource "azurerm_resource_group" "identity" {
  name     = var.resource_group_identity_name
  location = var.azure_location
}

resource "azurerm_resource_group" "agents" {
  count    = var.use_self_hosted_agents ? 1 : 0
  name     = var.resource_group_agents_name
  location = var.azure_location
}

resource "azurerm_resource_group" "network" {
  count    = var.use_private_networking ? 1 : 0
  name     = var.resource_group_network_name
  location = var.azure_location
}
