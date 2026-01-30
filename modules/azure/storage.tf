resource "azurerm_storage_account" "alz" {
  count                           = var.create_storage_account ? 1 : 0
  name                            = var.storage_account_name
  resource_group_name             = azurerm_resource_group.state[0].name
  location                        = var.azure_location
  account_tier                    = "Standard"
  account_replication_type        = var.storage_account_replication_type
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  public_network_access_enabled   = var.use_private_networking && var.use_self_hosted_agents && !var.allow_storage_access_from_my_ip ? false : true
  blob_properties {
    dynamic "delete_retention_policy" {
      for_each = var.storage_account_blob_soft_delete_enabled ? [1] : []
      content {
        days = var.storage_account_blob_soft_delete_retention_days
      }
    }
    versioning_enabled = var.storage_account_blob_versioning_enabled

    dynamic "container_delete_retention_policy" {
      for_each = var.storage_account_container_soft_delete_enabled ? [1] : []
      content {
        days = var.storage_account_container_soft_delete_retention_days
      }
    }
  }
  lifecycle {
    ignore_changes = [queue_properties, static_website]
  }
}

resource "azurerm_storage_account_network_rules" "alz" {
  count              = var.create_storage_account && var.use_private_networking ? 1 : 0
  storage_account_id = azurerm_storage_account.alz[0].id
  default_action     = "Deny"
  ip_rules           = var.allow_storage_access_from_my_ip ? [data.http.ip[0].response_body] : []
  bypass             = ["None"]
}

data "azapi_resource_id" "storage_account_blob_service" {
  count     = var.create_storage_account ? 1 : 0
  type      = "Microsoft.Storage/storageAccounts/blobServices@2022-09-01"
  parent_id = azurerm_storage_account.alz[0].id
  name      = "default"
}

resource "azapi_resource" "storage_account_container" {
  count     = var.create_storage_account ? 1 : 0
  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01"
  parent_id = data.azapi_resource_id.storage_account_blob_service[0].id
  name      = var.storage_container_name
  body = {
    properties = {
      publicAccess = "None"
    }
  }
  schema_validation_enabled = false
  depends_on                = [azurerm_storage_account_network_rules.alz]
}

resource "azurerm_role_assignment" "alz_storage_container" {
  for_each             = var.create_storage_account ? var.user_assigned_managed_identities : {}
  scope                = azapi_resource.storage_account_container[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.alz[each.key].principal_id
}

resource "azurerm_role_assignment" "alz_storage_container_additional" {
  for_each             = var.create_storage_account ? var.additional_role_assignment_principal_ids : {}
  scope                = azapi_resource.storage_account_container[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value
}
