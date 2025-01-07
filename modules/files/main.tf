locals {
  has_configuration_file = var.configuration_file_path != ""
}

locals {
  starter_module_files = { for file in fileset(var.starter_module_folder_path, "**") : file => {
    path = "${var.starter_module_folder_path}/${file}"
    } if(!local.has_configuration_file || !contains(var.built_in_configuration_file_names, file)) && !strcontains(file, var.starter_module_folder_path_exclusion)
  }

  additional_folders_files = length(var.additional_folders_path) != 0 ? merge(
    [for folder_path in var.additional_folders_path : { for file in fileset(folder_path, "**") : "${basename(folder_path)}/${file}" => {
      path = "${folder_path}/${file}"
      }
  }]...) : {}

  final_additional_files = concat(var.additional_files, local.has_configuration_file ? [var.configuration_file_path] : [])
  additional_repo_files = { for file in local.final_additional_files : basename(file) => {
    path = file
    }
  }
  all_repo_files = merge(local.starter_module_files, local.additional_repo_files, local.additional_folders_files)
}
