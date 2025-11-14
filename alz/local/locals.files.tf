locals {
  deploy_script_folder_path = local.is_bicep_avm ? "${path.module}/scripts-bicep-avm" : "${path.module}/scripts"
  is_bicep_iac_type  = contains(["bicep", "bicep-avm"], var.iac_type)
  is_classic_bicep   = var.iac_type == "bicep"
  is_bicep_avm       = var.iac_type == "bicep-avm"
}

locals {
  deploy_script_file_directory_path = local.is_bicep_iac_type ? local.deploy_script_folder_path : ""

  deploy_script_files = local.is_bicep_iac_type ? fileset(local.deploy_script_file_directory_path, "**/*.ps1") : []

  starter_module_config = local.is_bicep_iac_type ? jsondecode(file("${var.module_folder_path}/${local.bicep_config_file_path}")).starter_modules[var.starter_module_name] : null
  script_files_all      = local.is_bicep_iac_type ? local.starter_module_config.deployment_files : []

  target_folder_name = local.is_bicep_avm ? "scripts-bicep-avm" : "scripts"

  # Get a list of on-demand folders
  on_demand_folders = local.is_bicep_iac_type ? try(local.starter_module_config.on_demand_folders, []) : []

  networking_type = local.is_classic_bicep && fileexists("${var.module_folder_path}/${var.bicep_parameters_file_path}") ? jsondecode(file("${var.module_folder_path}/${var.bicep_parameters_file_path}")).NETWORK_TYPE : ""
  script_files = local.is_bicep_iac_type ? { for script_file in local.script_files_all : format("%03d", script_file.order) => {
    name                       = script_file.name
    displayName                = script_file.displayName
    templateFilePath           = script_file.templateFilePath
    templateParametersFilePath = script_file.templateParametersFilePath
    managementGroupIdVariable  = try("$env:${script_file.managementGroupId}", "\"\"")
    subscriptionIdVariable     = try("$env:${script_file.subscriptionId}", "\"\"")
    resourceGroupNameVariable  = try("$env:${script_file.resourceGroupName}", "\"\"")
    deploymentType             = script_file.deploymentType
    firstRunWhatIf             = local.is_classic_bicep ? format("%s%s", "$", script_file.firstRunWhatIf) : null
    group                      = script_file.group
  } if !local.is_classic_bicep || try(script_file.networkType, "") == "" || try(script_file.networkType, "") == local.networking_type } : {}

  deploy_script_files_parsed = { for deploy_script_file in local.deploy_script_files : "${local.target_folder_name}/${deploy_script_file}" =>
    {
      content = templatefile("${local.deploy_script_file_directory_path}/${deploy_script_file}", {
        script_files                   = local.script_files
        on_demand_folders              = local.on_demand_folders
        on_demand_folder_repository    = var.on_demand_folder_repository
        on_demand_folder_artifact_name = var.on_demand_folder_artifact_name
      })
    }
  }

  module_files = { for key, value in module.files.files : key =>
    {
      content = try(replace((file(value.path)), "# backend \"azurerm\" {}", (var.create_bootstrap_resources_in_azure ? "backend \"azurerm\" {}" : "backend \"local\" {}")), "unsupported_file_type")
    } if local.is_bicep_iac_type ? true : !endswith(key, ".ps1")
  }

  # Build a map of module files with types that are supported
  module_files_supported = { for key, value in local.module_files : key => value if value.content != "unsupported_file_type" && !endswith(key, "-cache.json") && !endswith(key, local.bicep_config_file_path) }

  # Build a list of files to exclude from the repository based on the on-demand folders
  excluded_module_files = distinct(flatten([for exclusion in local.on_demand_folders :
    [for key, value in local.module_files_supported : key if startswith(key, exclusion.target)]
  ]))

  # Filter out the excluded files
  module_files_filtered = { for key, value in local.module_files_supported : key => value if !contains(local.excluded_module_files, key) }

  final_module_files = merge(local.module_files_filtered, local.deploy_script_files_parsed)
}
