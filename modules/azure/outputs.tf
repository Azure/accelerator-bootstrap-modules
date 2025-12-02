output "user_assigned_managed_identity_client_ids" {
  description = "Map of user-assigned managed identity keys to their client IDs. Client IDs are used for OIDC authentication in CI/CD pipelines and for configuring service connections."
  value       = { for key, value in var.user_assigned_managed_identities : key => azurerm_user_assigned_identity.alz[key].client_id }
}

output "role_assignments" {
  description = "Complete configuration of all role assignments created for managed identities and additional principals. Includes role definition details, scope information, and principal assignments for audit and verification purposes."
  value       = local.role_assignments
}
