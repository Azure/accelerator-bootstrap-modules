locals {
  agent_pool_configuration  = var.use_self_hosted_agents ? "name: ${local.resource_names.version_control_system_agent_pool}" : "vmImage: ubuntu-latest"
  repository_name_templates = var.use_separate_repository_for_templates ? local.resource_names.version_control_system_repository_templates : local.resource_names.version_control_system_repository

  is_bicep_iac_type = var.iac_type == "bicep" || var.iac_type == "bicep-avm"
  is_classic_bicep  = var.iac_type == "bicep"
  is_bicep_avm      = var.iac_type == "bicep-avm"
  iac_type_for_pipelines = var.iac_type  # Use actual iac_type for pipeline directory

  pipeline_files_directory_path          = "${path.module}/pipelines/${local.iac_type_for_pipelines}/main"
  pipeline_template_files_directory_path = "${path.module}/pipelines/${local.iac_type_for_pipelines}/templates"

  pipeline_files          = fileset(local.pipeline_files_directory_path, "**/*.yaml")
  pipeline_template_files = fileset(local.pipeline_template_files_directory_path, "**/*.yaml")

  target_folder_name = ".pipelines"

  starter_module_config = local.is_bicep_iac_type ? jsondecode(file("${var.module_folder_path}/${var.bicep_config_file_path}")).starter_modules[var.starter_module_name] : null
  script_files_all      = local.is_bicep_iac_type ? local.starter_module_config.deployment_files : []
  destroy_script_path   = local.is_bicep_iac_type ? local.starter_module_config.destroy_script_path : ""

  # Get a list of on-demand folders
  on_demand_folders = local.is_classic_bicep ? local.starter_module_config.on_demand_folders : []

  networking_type = local.is_bicep_avm ? var.network_type : (local.is_classic_bicep && fileexists("${var.module_folder_path}/${var.bicep_parameters_file_path}") ? jsondecode(file("${var.module_folder_path}/${var.bicep_parameters_file_path}")).NETWORK_TYPE : "")
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

  # CI / CD Top Level Files
  cicd_files = { for pipeline_file in local.pipeline_files : "${local.target_folder_name}/${pipeline_file}" =>
    {
      content = templatefile("${local.pipeline_files_directory_path}/${pipeline_file}", {
        project_name                     = var.azure_devops_project_name
        repository_name_templates        = local.repository_name_templates
        ci_template_path                 = "${local.target_folder_name}/${local.ci_template_file_name}"
        cd_template_path                 = "${local.target_folder_name}/${local.cd_template_file_name}"
        script_files                     = local.script_files
        script_file_groups               = local.script_file_groups
        root_module_folder_relative_path = var.root_module_folder_relative_path
      })
    }
  }

  # CI / CD Template Files
  cicd_template_files = { for pipeline_template_file in local.pipeline_template_files : "${local.target_folder_name}/${pipeline_template_file}" =>
    {
      content = templatefile("${local.pipeline_template_files_directory_path}/${pipeline_template_file}", {
        agent_pool_configuration       = local.agent_pool_configuration
        environment_name_plan          = local.resource_names.version_control_system_environment_plan
        environment_name_apply         = local.resource_names.version_control_system_environment_apply
        variable_group_name            = local.resource_names.version_control_system_variable_group
        project_name                   = var.azure_devops_project_name
        repository_name_templates      = local.repository_name_templates
        service_connection_name_plan   = local.resource_names.version_control_system_service_connection_plan
        service_connection_name_apply  = local.resource_names.version_control_system_service_connection_apply
        self_hosted_agent              = var.use_self_hosted_agents
        script_files                   = local.script_files
        destroy_script_path            = local.destroy_script_path
        on_demand_folders              = local.on_demand_folders
        on_demand_folder_repository    = var.on_demand_folder_repository
        on_demand_folder_artifact_name = var.on_demand_folder_artifact_name
      })
    }
  }

  # Build a map of module files and turn on the terraform backend block
  module_files = { for key, value in module.files.files : key =>
    {
      content = try(replace((file(value.path)), "# backend \"azurerm\" {}", "backend \"azurerm\" {}"), "unsupported_file_type")
    }
  }

  # Build a map of module files with subscription ID replacements
  module_files_with_subscriptions = { for key, value in local.module_files : key =>
    {
      content = replace(
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
      )
    }
  }

  architecture_definition_file = local.has_architecture_definition ? {
    "${var.root_module_folder_relative_path}/lib/architecture_definitions/${local.architecture_definition_name}.alz_architecture_definition.json" = {
      content = module.architecture_definition[0].architecture_definition_json
    }
  } : {}

  # Build a map of module files with types that are supported
  module_files_supported = { for key, value in local.module_files_with_subscriptions : key => value if value.content != "unsupported_file_type" && !endswith(key, "-cache.json") && !endswith(key, var.bicep_config_file_path) }

  # Build a list of files to exclude from the repository based on the on-demand folders
  excluded_module_files = distinct(flatten([for exclusion in local.on_demand_folders :
    [for key, value in local.module_files_supported : key if startswith(key, exclusion.target)]
  ]))

  # Filter out the excluded files
  module_files_filtered = { for key, value in local.module_files_supported : key => value if !contains(local.excluded_module_files, key) }

  # Create final maps of all files to be included in the repositories
  repository_files          = merge(local.cicd_files, local.module_files_filtered, var.use_separate_repository_for_templates ? {} : local.cicd_template_files, local.architecture_definition_file)
  template_repository_files = var.use_separate_repository_for_templates ? local.cicd_template_files : {}
}
