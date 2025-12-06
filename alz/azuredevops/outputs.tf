output "details" {
  description = "The details of the settings used"
  value = {
    iac_type            = var.iac_type
    starter_module_name = var.starter_module_name
  }
}

output "test" {
  value = module.file_manipulation.test
}