locals {
  is_bicep_iac_type = contains(["bicep", "bicep-classic"], var.iac_type)
  is_bicep_classic  = var.iac_type == "bicep-classic"

  bicep_parameters = try(jsondecode(file("${var.module_folder_path}/${var.bicep_parameters_file_path}")), {})
  networking_type  = local.is_bicep_iac_type ? try(local.bicep_parameters.network_type, local.bicep_parameters.networkType) : ""
}

locals {
  bicep_module_files_defaults_found = distinct(flatten([for key, value in local.module_files_filtered : [
    for template in regexall("(\\{\\{[\\s]*.*?[\\s]*\\}\\})", value.content) :
    replace(replace(template[0], "{{", ""), "}}", "") if length(template) > 0 && strcontains(template[0], "||")
    ] if endswith(key, ".bicepparam")
  ]))

  bicep_module_files_defaults = { for item in local.bicep_module_files_defaults_found :
    (split("||", item)[0]) => split("||", item)[1]
  }
}

locals {
  bicep_module_files_prepped_for_templating = { for key, value in local.module_files_filtered : key =>
    {
      content = replace(replace(replace(replace(value.content, "/(\\|\\|[\\s]*.*?[\\s]*\\}\\})/", "}}"), "$${", "$$${"), "{{", "$${"), "}}", "}")
    } if endswith(key, ".bicepparam")
  }

  bicep_module_files_templated = { for key, value in local.bicep_module_files_prepped_for_templating : key =>
    {
      content = replace(templatestring(value.content, local.bicep_module_file_replacements), "$$${", "$${")
    }
  }

  bicep_module_file_replacements = merge({
    unique_postfix       = var.resource_names.unique_postfix
    time_stamp           = var.resource_names.time_stamp
    time_stamp_formatted = var.resource_names.time_stamp_formatted
    },
    local.bicep_module_files_defaults,
  local.bicep_parameters)
}

locals {
  id_variable_template       = local.is_github ? "$${{ env.%s }}" : (local.is_azuredevops ? "$(%s)" : "$env:%s")
  id_variable_template_empty = local.is_github ? "" : (local.is_azuredevops ? "" : "\"\"")

  script_files = local.is_bicep_iac_type ? { for script_file in local.script_files_all : format("%03d", script_file.order) => {
    name                       = replace(replace(script_file.name, "{{unique_postfix}}", var.resource_names.unique_postfix), "{{time_stamp}}", var.resource_names.time_stamp_formatted)
    displayName                = replace(replace(script_file.displayName, "{{unique_postfix}}", var.resource_names.unique_postfix), "{{time_stamp}}", var.resource_names.time_stamp_formatted)
    templateFilePath           = script_file.templateFilePath
    templateParametersFilePath = script_file.templateParametersFilePath
    managementGroupIdVariable  = try(format(local.id_variable_template, script_file.managementGroupId), local.id_variable_template_empty)
    subscriptionIdVariable     = try(format(local.id_variable_template, script_file.subscriptionId), local.id_variable_template_empty)
    resourceGroupNameVariable  = try(format(local.id_variable_template, script_file.resourceGroupName), local.id_variable_template_empty)
    deploymentType             = script_file.deploymentType
    firstRunWhatIf             = local.is_local ? format("$%s", script_file.firstRunWhatIf) : script_file.firstRunWhatIf
    group                      = script_file.group
    networkType                = try(script_file.networkType, "")
  } if try(script_file.networkType, "") == "" || try(script_file.networkType, "") == local.networking_type } : {}

  script_file_groups_all = local.is_bicep_iac_type ? local.starter_module_config.deployment_file_groups : []

  used_script_file_groups = distinct([for script_file in local.script_files_all : script_file.group])

  script_file_groups = { for script_file_group in local.script_file_groups_all : format("%03d", script_file_group.order) => {
    name        = script_file_group.name
    displayName = script_file_group.displayName
    } if contains(local.used_script_file_groups, script_file_group.name)
  }
}

locals {
  # Get a list of on-demand folders
  on_demand_folders = local.is_bicep_classic ? local.starter_module_config.on_demand_folders : []
}
