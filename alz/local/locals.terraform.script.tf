locals {
  command_replacements = {
    root_module_folder_relative_path    = var.root_module_folder_relative_path
    remote_state_resource_group_name    = var.create_bootstrap_resources_in_azure ? local.resource_names.resource_group_state : ""
    remote_state_storage_account_name   = var.create_bootstrap_resources_in_azure ? local.resource_names.storage_account : ""
    remote_state_storage_container_name = var.create_bootstrap_resources_in_azure ? local.resource_names.storage_container : ""
  }

  command_final = templatefile("${path.module}/templates/terraform-deploy-local.ps1", local.command_replacements)
}
