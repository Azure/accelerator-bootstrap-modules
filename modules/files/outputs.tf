output "files" {
  description = "Map of all collected files from the starter module, additional files, and additional folders. Each entry contains the file path (relative to repository root) and source path for reading content. This output is used by the file_manipulation module for processing."
  value       = local.all_repo_files
}
