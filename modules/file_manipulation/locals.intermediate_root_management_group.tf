# Get the intermediate root management group from the terraform architecture file or bicep parameters
locals {
  is_terraform_iac_type                        = var.iac_type == "terraform"
  terraform_architecture_file_path             = "${var.module_folder_path}/${var.terraform_architecture_file_path}"
  terraform_architecture_file_extension        = split(".", var.terraform_architecture_file_path)[length(split(".", var.terraform_architecture_file_path)) - 1]
  terraform_architecture_file_is_yaml          = local.terraform_architecture_file_extension == "yaml" || local.terraform_architecture_file_extension == "yml"
  terraform_architecture                       = local.is_terraform_iac_type ? (local.terraform_architecture_file_is_yaml ? yamldecode(file(local.terraform_architecture_file_path)) : jsondecode(file(local.terraform_architecture_file_path))) : null
  terraform_intermediate_root_management_group = local.is_terraform_iac_type ? ([for management_group in local.terraform_architecture.management_groups : management_group if management_group.parent_id == null])[0] : null
  intermediate_root_management_group = local.is_terraform_iac_type ? {
    id           = local.terraform_intermediate_root_management_group.id
    display_name = local.terraform_intermediate_root_management_group.display_name
    } : {
    id           = try("${local.bicep_parameters.management_group_id_prefix}${local.bicep_parameters.management_group_int_root_id}${local.bicep_parameters.management_group_id_postfix}", "")
    display_name = try("${local.bicep_parameters.management_group_name_prefix}${local.bicep_parameters.management_group_int_root_name}${local.bicep_parameters.management_group_name_postfix}", "")
  }
}

# Transform the intermediate root management group in the terraform architecture file to ensure it is marked as existing
locals {
  terraform_management_groups_non_root = local.is_terraform_iac_type ? [for management_group in local.terraform_architecture.management_groups : management_group if management_group.parent_id != null] : null
  terraform_intermediate_root_management_group_updated = local.is_terraform_iac_type ? merge(
    local.terraform_intermediate_root_management_group,
    {
      exists = true
    }
  ) : null
  terraform_architecture_file_content_final = local.is_terraform_iac_type ? merge(
    local.terraform_architecture,
    {
      management_groups = concat(
        [local.terraform_intermediate_root_management_group_updated],
        local.terraform_management_groups_non_root
      )
    }
  ) : null

  terraform_architecture_files = local.is_terraform_iac_type ? {
    (var.terraform_architecture_file_path) = {
      content = local.terraform_architecture_file_is_yaml ? yamlencode(local.terraform_architecture_file_content_final) : jsonencode(local.terraform_architecture_file_content_final)
    }
  } : {}
}
