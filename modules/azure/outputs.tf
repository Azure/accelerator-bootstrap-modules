output "user_assigned_managed_identity_client_ids" {
  value       = var.managed_identity_client_ids
  description = "Map of managed identity client IDs (passed through from identities module)"
}

output "role_assignments" {
  description = "Complete configuration of all role assignments created for managed identities and additional principals. Includes role definition details, scope information, and principal assignments for audit and verification purposes."
  value       = local.role_assignments
}
