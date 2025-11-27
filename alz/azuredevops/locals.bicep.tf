locals {
    is_bicep_iac_type         = contains(["bicep", "bicep-classic"], var.iac_type)
    is_bicep_classic          = var.iac_type == "bicep-classic"
    is_bicep                  = var.iac_type == "bicep"

    bicep_parameters = local.is_bicep_iac_type && fileexists("${var.module_folder_path}/${var.bicep_parameters_file_path}") ? jsondecode(file("${var.module_folder_path}/${var.bicep_parameters_file_path}")) : {}
    networking_type = local.is_bicep_iac_type ? local.bicep_parameters.NETWORK_TYPE : ""
}

locals {
  bicep_module_files_prepped_for_templating = { for key, value in local.module_files_filtered : key =>
    {
      content = replace(replace(value.content, "{{", "$${"), "}}", "}")
    } if endswith(key, ".bicepparam")
  }

  bicep_module_files_templated = { for key, value in local.bicep_module_files_prepped_for_templating : key =>
    {
      content = templatestring(value.content, local.module_file_replacements)
    }
  }

  module_file_replacements = {
    management_subscription_id = try(var.subscription_ids["management"], var.subscription_id_management, "")
    connectivity_subscription_id = try(var.subscription_ids["connectivity"], var.subscription_id_connectivity, "")
    identity_subscription_id     = try(var.subscription_ids["identity"], var.subscription_id_identity, "")
    security_subscription_id     = try(var.subscription_ids["security"], "")
    primary_location            = try(local.bicep_parameters.LOCATION_PRIMARY, "eastus")
    secondary_location          = try(local.bicep_parameters.LOCATION_SECONDARY, "westus")
    root_parent_management_group_id = var.root_parent_management_group_id
  }
}

locals {
  script_files = local.is_bicep_iac_type ? { for script_file in local.script_files_all : format("%03d", script_file.order) => {
    name                       = script_file.name
    displayName                = script_file.displayName
    templateFilePath           = script_file.templateFilePath
    templateParametersFilePath = script_file.templateParametersFilePath
    managementGroupIdVariable  = try("$(${script_file.managementGroupId})", "")
    subscriptionIdVariable     = try("$(${script_file.subscriptionId})", "")
    resourceGroupNameVariable  = try("$(${script_file.resourceGroupName})", "")
    deploymentType             = script_file.deploymentType
    firstRunWhatIf             = script_file.firstRunWhatIf
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
