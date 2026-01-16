output "repository_files" {
  description = "Map of repository files with their content"
  value       = merge(local.repository_files, local.terraform_architecture_files)
}

output "template_repository_files" {
  description = "Map of template repository files with their content"
  value       = local.template_repository_files
}

output "intermediate_root_management_group_id" {
  description = "The ID of the intermediate root management group from the Terraform architecture"
  value       = local.intermediate_root_management_group.id
}

output "intermediate_root_management_group_display_name" {
  description = "The display name of the intermediate root management group from the Terraform architecture"
  value       = local.intermediate_root_management_group.display_name
}
