output "user_assigned_managed_identity_client_ids" {
  value       = var.managed_identity_client_ids
  description = "Map of managed identity client IDs (passed through from identities module)"
}

output "role_assignments" {
  value = local.role_assignments
}
