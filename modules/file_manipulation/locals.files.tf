locals {
  is_github                             = var.vcs_type == "github"
  is_azuredevops                        = var.vcs_type == "azuredevops"
  is_local                              = var.vcs_type == "local"
  use_separate_repository_for_templates = coalesce(var.use_separate_repository_for_templates, false)
  repository_name_templates             = local.use_separate_repository_for_templates ? var.resource_names.version_control_system_repository_templates : try(var.resource_names.version_control_system_repository, "")

  pipeline_files          = var.pipeline_files_directory_path == null ? [] : fileset(var.pipeline_files_directory_path, "**/*.*")
  pipeline_template_files = var.pipeline_template_files_directory_path == null ? [] : fileset(var.pipeline_template_files_directory_path, "**/*.*")

  # Select config file based on IAC type
  starter_module_config = local.is_bicep_iac_type ? jsondecode(file("${var.module_folder_path}/${var.bicep_config_file_path}")).starter_modules[var.starter_module_name] : null
  script_files_all      = local.is_bicep_iac_type ? local.starter_module_config.deployment_files : []
  destroy_script_path   = local.is_bicep_iac_type ? local.starter_module_config.destroy_script_path : ""

  templated_files = {
    main_files = {
      source_directory_path = var.pipeline_files_directory_path
      files                 = local.pipeline_files
    }
    template_files = {
      source_directory_path = var.pipeline_template_files_directory_path
      files                 = local.pipeline_template_files
    }
  }

  templated_files_final = { for key, value in local.templated_files : key => {
    for pipeline_file in value.files : "${var.pipeline_target_folder_name}/${pipeline_file}" => {
      content = templatefile("${value.source_directory_path}/${pipeline_file}", {
        agent_pool_or_runner_configuration = var.agent_pool_or_runner_configuration
        environment_name_plan              = try(var.resource_names.version_control_system_environment_plan, "")
        environment_name_apply             = try(var.resource_names.version_control_system_environment_apply, "")
        variable_group_name                = local.is_azuredevops ? var.resource_names.version_control_system_variable_group : ""
        project_or_organization_name       = var.project_or_organization_name
        repository_name_templates          = local.repository_name_templates
        service_connection_name_plan       = local.is_azuredevops ? var.resource_names.version_control_system_service_connection_plan : ""
        service_connection_name_apply      = local.is_azuredevops ? var.resource_names.version_control_system_service_connection_apply : ""
        self_hosted_agent                  = var.use_self_hosted_agents_runners
        script_files                       = local.script_files
        destroy_script_path                = local.destroy_script_path
        on_demand_folders                  = local.on_demand_folders
        on_demand_folder_repository        = var.on_demand_folder_repository
        on_demand_folder_artifact_name     = var.on_demand_folder_artifact_name
        concurrency_value                  = var.concurrency_value
        ci_template_path                   = "${var.pipeline_target_folder_name}/${coalesce(var.ci_template_file_name, "empty")}"
        cd_template_path                   = "${var.pipeline_target_folder_name}/${coalesce(var.cd_template_file_name, "empty")}"
        script_file_groups                 = local.script_file_groups
        root_module_folder_relative_path   = var.root_module_folder_relative_path
    }) }
    }
  }
}

locals {
  # Build a map of module files and turn on the terraform backend block
  module_files = { for key, value in var.files : key =>
    {
      content = try(replace((file(value.path)), "# backend \"azurerm\" {}", "backend \"azurerm\" {}"), "unsupported_file_type")
    }
  }

  # Build a map of module files with types that are supported
  module_files_supported = { for key, value in local.module_files : key => value if value.content != "unsupported_file_type" && !endswith(key, "-cache.json") && !endswith(key, var.bicep_config_file_path) && !endswith(key, var.bicep_parameters_file_path) }

  # Build a list of files to exclude from the repository based on the on-demand folders
  excluded_module_files = distinct(flatten([for exclusion in local.on_demand_folders :
    [for key, value in local.module_files_supported : key if startswith(key, exclusion.target)]
  ]))

  # Filter out the excluded files
  module_files_filtered = { for key, value in local.module_files_supported : key => value if !contains(local.excluded_module_files, key) }

  # Create final maps of all files to be included in the repositories
  repository_files          = merge(local.templated_files_final.main_files, local.module_files_filtered, local.use_separate_repository_for_templates ? {} : local.templated_files_final.template_files, local.bicep_module_files_templated)
  template_repository_files = local.use_separate_repository_for_templates ? local.templated_files_final.template_files : {}
}
