locals {
  private_endpoints = var.use_private_networking && var.use_self_hosted_agents ? merge(var.create_storage_account ? {
    storage_account = {
      name         = var.storage_account_private_endpoint_name
      resource_id  = azurerm_storage_account.alz[0].id
      dns_record   = "privatelink.blob.core.windows.net"
      sub_resource = "blob"
    }
    } : {},
    {
      container_registry = {
        name         = var.container_registry_private_endpoint_name
        resource_id  = azurerm_container_registry.alz[0].id
        dns_record   = "privatelink.azurecr.io"
        sub_resource = "registry"
      }
  }) : {}
}

resource "azurerm_private_dns_zone" "alz" {
  for_each            = local.private_endpoints
  name                = each.value.dns_record
  resource_group_name = azurerm_resource_group.network[0].name
}

resource "azurerm_private_dns_zone_virtual_network_link" "alz" {
  for_each              = local.private_endpoints
  name                  = each.value.name
  resource_group_name   = azurerm_resource_group.network[0].name
  private_dns_zone_name = azurerm_private_dns_zone.alz[each.key].name
  virtual_network_id    = azurerm_virtual_network.alz[0].id
}

resource "azurerm_private_endpoint" "alz" {
  for_each            = local.private_endpoints
  name                = each.value.name
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.network[0].name
  subnet_id           = azurerm_subnet.private_endpoints[0].id

  private_service_connection {
    name                           = each.value.name
    private_connection_resource_id = each.value.resource_id
    subresource_names              = [each.value.sub_resource]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = each.value.name
    private_dns_zone_ids = [azurerm_private_dns_zone.alz[each.key].id]
  }
}
