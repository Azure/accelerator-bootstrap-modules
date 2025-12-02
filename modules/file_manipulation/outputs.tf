output "repository_files" {
  description = "Map of repository files with their content"
  value       = local.repository_files
}

output "template_repository_files" {
  description = "Map of template repository files with their content"
  value       = local.template_repository_files
}
