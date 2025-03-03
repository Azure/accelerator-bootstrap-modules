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
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_user_assigned_identity.alz[each.key].principal_id
}

resource "azurerm_role_assignment" "alz_storage_container_additional" {
  for_each             = var.create_storage_account ? var.additional_role_assignment_principal_ids : {}
  scope                = azapi_resource.storage_account_container[0].id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = each.value
}

# These role assignments are a temporary addition to handle this issue in the Terraform CLI: https://github.com/hashicorp/terraform/issues/36595
# They will be removed once the issue has been resolved
resource "azurerm_role_assignment" "alz_storage_reader" {
  for_each             = var.create_storage_account ? var.user_assigned_managed_identities : {}
  scope                = azurerm_storage_account.alz[0].id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.alz[each.key].principal_id
}

resource "azurerm_role_assignment" "alz_storage_reader_additional" {
  for_each             = var.create_storage_account ? var.additional_role_assignment_principal_ids : {}
  scope                = azurerm_storage_account.alz[0].id
  role_definition_name = "Reader"
  principal_id         = each.value
}
