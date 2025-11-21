locals {
  deploy_script_folder_path = local.is_bicep_avm ? "${path.module}/scripts-bicep-avm" : "${path.module}/scripts"
  is_bicep_iac_type  = contains(["bicep", "bicep-avm"], var.iac_type)
  is_classic_bicep   = var.iac_type == "bicep"
  is_bicep_avm       = var.iac_type == "bicep-avm"
}

locals {
  deploy_script_file_directory_path = local.is_bicep_iac_type ? local.deploy_script_folder_path : ""

  deploy_script_files = local.is_bicep_iac_type ? fileset(local.deploy_script_file_directory_path, "**/*.ps1") : []

  # Select config file based on IAC type
  config_file_path = local.is_bicep_avm ? var.bicep_avm_config_file_path : local.bicep_config_file_path

  starter_module_config = local.is_bicep_iac_type ? jsondecode(file("${var.module_folder_path}/${local.config_file_path}")).starter_modules[var.starter_module_name] : null
  script_files_all      = local.is_bicep_iac_type ? local.starter_module_config.deployment_files : []

  target_folder_name = local.is_bicep_avm ? "scripts-bicep-avm" : "scripts"

  # Get a list of on-demand folders (only for classic bicep, not bicep-avm)
  on_demand_folders = local.is_classic_bicep ? try(local.starter_module_config.on_demand_folders, []) : []

  networking_type = local.is_bicep_avm ? var.network_type : (local.is_classic_bicep && fileexists("${var.module_folder_path}/${var.bicep_parameters_file_path}") ? jsondecode(file("${var.module_folder_path}/${var.bicep_parameters_file_path}")).NETWORK_TYPE : "")
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
    networkType                = try(script_file.networkType, "")
  } if try(script_file.networkType, "") == "" || try(script_file.networkType, "") == local.networking_type } : {}

  deploy_script_files_parsed = { for deploy_script_file in local.deploy_script_files : "${local.target_folder_name}/${deploy_script_file}" =>
    {
      content = templatefile("${local.deploy_script_file_directory_path}/${deploy_script_file}", {
        script_files                   = local.script_files
        on_demand_folders              = local.is_classic_bicep ? local.on_demand_folders : []
        on_demand_folder_repository    = local.is_classic_bicep ? var.on_demand_folder_repository : ""
        on_demand_folder_artifact_name = local.is_classic_bicep ? var.on_demand_folder_artifact_name : ""
      })
    }
  }

  # Add parameters.json for bicep-avm in root directory
  parameters_json_file = local.is_bicep_avm ? {
    "parameters.json" = {
      content = templatefile("${local.deploy_script_file_directory_path}/parameters.json.tftpl", {
        management_group_id          = local.root_parent_management_group_id
        subscription_id_management   = try(var.subscription_ids["management"], var.subscription_id_management, "")
        subscription_id_identity     = try(var.subscription_ids["identity"], var.subscription_id_identity, "")
        subscription_id_connectivity = try(var.subscription_ids["connectivity"], var.subscription_id_connectivity, "")
        subscription_id_security     = try(var.subscription_ids["security"], var.subscription_id_security, "")
        location                     = var.bootstrap_location
        network_type                 = local.networking_type
      })
    }
  } : {}

  module_files = { for key, value in module.files.files : key =>
    {
      content = try(replace((file(value.path)), "# backend \"azurerm\" {}", (var.create_bootstrap_resources_in_azure ? "backend \"azurerm\" {}" : "backend \"local\" {}")), "unsupported_file_type")
    } if local.is_bicep_iac_type ? true : !endswith(key, ".ps1")
  }

  # Replace subscription ID and location placeholders in .bicepparam files
  module_files_with_subscriptions = { for key, value in local.module_files : key =>
    {
      content = endswith(key, ".bicepparam") ? replace(
        replace(
          replace(
            replace(
              replace(
                replace(
                  value.content,
                  "{{your-management-subscription-id}}",
                  try(var.subscription_ids["management"], var.subscription_id_management, "")
                ),
                "{{your-connectivity-subscription-id}}",
                try(var.subscription_ids["connectivity"], var.subscription_id_connectivity, "")
              ),
              "{{your-identity-subscription-id}}",
              try(var.subscription_ids["identity"], var.subscription_id_identity, "")
            ),
            "{{your-security-subscription-id}}",
            try(var.subscription_ids["security"], var.subscription_id_security, "")
          ),
          "{{location-0}}",
          try(var.starter_locations[0], var.bootstrap_location)
        ),
        "{{location-1}}",
        try(var.starter_locations[1], var.bootstrap_location)
      ) : value.content
    }
  }

  # Replace location tokens in .bicepparam files
  module_files_with_locations = { for key, value in local.module_files_with_subscriptions : key =>
    {
      content = endswith(key, ".bicepparam") ? replace(
        replace(
          value.content,
          "{{location-0}}",
          try(var.starter_locations[0], "eastus")
        ),
        "{{location-1}}",
        try(var.starter_locations[1], "westus")
      ) : value.content
    }
  }

  # Build a map of module files with types that are supported
  module_files_supported = { for key, value in local.module_files_with_locations : key => value if value.content != "unsupported_file_type" && !endswith(key, "-cache.json") && !endswith(key, local.config_file_path) }

  # Build a list of files to exclude from the repository based on the on-demand folders (only for classic bicep)
  excluded_module_files = local.is_classic_bicep ? distinct(flatten([for exclusion in local.on_demand_folders :
    [for key, value in local.module_files_supported : key if startswith(key, exclusion.target)]
  ])) : []

  # For bicep-avm, exclude networking folders based on network_type
  excluded_networking_files = local.is_bicep_avm && local.networking_type != "" ? flatten([
    local.networking_type == "hubNetworking" ? [for key, value in local.module_files_supported : key if startswith(key, "templates/networking/virtualwan")] : [],
    local.networking_type == "vwanConnectivity" ? [for key, value in local.module_files_supported : key if startswith(key, "templates/networking/hubnetworking")] : [],
    local.networking_type == "none" ? [for key, value in local.module_files_supported : key if startswith(key, "templates/networking/")] : []
  ]) : []

  # Combine all excluded files
  all_excluded_files = distinct(concat(local.excluded_module_files, local.excluded_networking_files))

  # Filter out the excluded files
  module_files_filtered = { for key, value in local.module_files_supported : key => value if !contains(local.all_excluded_files, key) }

  final_module_files = merge(local.module_files_filtered, local.deploy_script_files_parsed, local.parameters_json_file)
}
