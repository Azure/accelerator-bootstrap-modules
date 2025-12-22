# Identity Resource Group
resource "azurerm_resource_group" "identity" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# User Assigned Managed Identities
resource "azurerm_user_assigned_identity" "identities" {
  for_each            = var.managed_identities
  name                = each.value
  location            = var.location
  resource_group_name = azurerm_resource_group.identity.name
  tags                = var.tags
}

# Federated Identity Credentials (for workload identity federation)
resource "azurerm_federated_identity_credential" "credentials" {
  for_each            = var.federated_credentials
  name                = each.value.federated_credential_name
  resource_group_name = azurerm_resource_group.identity.name
  audience            = each.value.audience
  issuer              = each.value.federated_credential_issuer
  parent_id           = azurerm_user_assigned_identity.identities[each.value.user_assigned_managed_identity_key].id
  subject             = each.value.federated_credential_subject
}
