output "resource_group_name" {
  value       = azurerm_resource_group.identity.name
  description = "Name of the identity resource group"
}

output "resource_group_id" {
  value       = azurerm_resource_group.identity.id
  description = "Resource ID of the identity resource group"
}

output "managed_identity_ids" {
  value       = { for k, v in azurerm_user_assigned_identity.identities : k => v.id }
  description = "Map of managed identity resource IDs (key = logical name)"
}

output "managed_identity_client_ids" {
  value       = { for k, v in azurerm_user_assigned_identity.identities : k => v.client_id }
  description = "Map of managed identity client IDs for authentication (key = logical name)"
}

output "managed_identity_principal_ids" {
  value       = { for k, v in azurerm_user_assigned_identity.identities : k => v.principal_id }
  description = "Map of managed identity principal IDs for role assignments (key = logical name)"
}

output "federated_credential_ids" {
  value       = { for k, v in azurerm_federated_identity_credential.credentials : k => v.id }
  description = "Map of federated credential IDs"
}
