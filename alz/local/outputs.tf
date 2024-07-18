output "module_output_directory_path" {
  description = "The path to the directory where the module files have been created."
  value       = abspath(local.target_directory)
}

output "details" {
  description = "The details of the settings used"
  value = {
    iac_type            = var.iac_type
    starter_module_name = var.starter_module_name
  }
}
