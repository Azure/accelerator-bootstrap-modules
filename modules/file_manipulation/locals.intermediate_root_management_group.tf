locals {
  is_terraform_iac_type                        = var.iac_type == "terraform"
  terraform_architecture                       = local.is_terraform_iac_type ? endswith(var.terraform_architecture_file_path, ".yaml") || endswith(var.terraform_architecture_file_path, ".json") ? yamldecode(file("${var.module_folder_path}/${var.terraform_architecture_file_path}")) : jsondecode(file("${var.module_folder_path}/${var.terraform_architecture_file_path}")) : null
  terraform_intermediate_root_management_group = local.is_terraform_iac_type ? ([for management_group in local.terraform_architecture.management_groups : management_group if management_group.parent_id == null])[0] : null
  intermediate_root_management_group = local.is_terraform_iac_type ? {
    id           = local.terraform_intermediate_root_management_group.id
    display_name = local.terraform_intermediate_root_management_group.display_name
    } : {
    id           = try("${local.bicep_parameters.management_group_id_prefix}${local.bicep_parameters.management_group_int_root_id}${local.bicep_parameters.management_group_id_postfix}", "")
    display_name = try("${local.bicep_parameters.management_group_name_prefix}${local.bicep_parameters.management_group_int_root_name}${local.bicep_parameters.management_group_name_postfix}", "")
  }
}

locals {
  import_block = <<EOT
import {
  to = azapi_resource.management_groups_level_0["${local.intermediate_root_management_group.id}"]
  id = "/providers/Microsoft.Management/managementGroups/${local.intermediate_root_management_group.id}"
}
EOT

  import_block_files = local.is_terraform_iac_type ? {
    "imports.management_groups.tf" = {
      content = local.import_block
    }
  } : {}
}
