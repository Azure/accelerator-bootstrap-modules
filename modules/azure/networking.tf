resource "azurerm_virtual_network" "alz" {
  count               = var.use_private_networking && var.use_self_hosted_agents ? 1 : 0
  name                = var.virtual_network_name
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.network[0].name
  address_space       = [var.virtual_network_address_space]
}

resource "azurerm_public_ip" "alz" {
  count               = var.use_private_networking && var.use_self_hosted_agents ? 1 : 0
  name                = var.public_ip_name
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.network[0].name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "alz" {
  count               = var.use_private_networking && var.use_self_hosted_agents ? 1 : 0
  name                = var.nat_gateway_name
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.network[0].name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "alz" {
  count                = var.use_private_networking && var.use_self_hosted_agents ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.alz[0].id
  public_ip_address_id = azurerm_public_ip.alz[0].id
}

resource "azurerm_subnet" "container_instances" {
  count                             = var.use_private_networking && var.use_self_hosted_agents ? 1 : 0
  name                              = var.virtual_network_subnet_name_container_instances
  resource_group_name               = azurerm_resource_group.network[0].name
  virtual_network_name              = azurerm_virtual_network.alz[0].name
  address_prefixes                  = [var.virtual_network_subnet_address_prefix_container_instances]
  private_endpoint_network_policies = "Enabled"
  delegation {
    name = "aci-delegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet_nat_gateway_association" "container_instances" {
  count          = var.use_private_networking && var.use_self_hosted_agents ? 1 : 0
  subnet_id      = azurerm_subnet.container_instances[0].id
  nat_gateway_id = azurerm_nat_gateway.alz[0].id
}

resource "azurerm_subnet" "private_endpoints" {
  count                             = var.use_private_networking && var.use_self_hosted_agents ? 1 : 0
  name                              = var.virtual_network_subnet_name_private_endpoints
  resource_group_name               = azurerm_resource_group.network[0].name
  virtual_network_name              = azurerm_virtual_network.alz[0].name
  address_prefixes                  = [var.virtual_network_subnet_address_prefix_private_endpoints]
  private_endpoint_network_policies = "Enabled"
}
