locals {
  agent_pool_configuration  = var.use_self_hosted_agents ? "name: ${local.resource_names.version_control_system_agent_pool}" : "vmImage: ubuntu-latest"
  repository_name_templates = var.use_separate_repository_for_pipeline_templates ? local.resource_names.version_control_system_repository_templates : local.resource_names.version_control_system_repository

  pipeline_files_directory_path          = "${path.module}/pipelines/${var.iac_type}"
  pipeline_template_files_directory_path = "${path.module}/pipelines/${var.iac_type}/templates"

  pipeline_files          = fileset(local.pipeline_files_directory_path, "*.yaml")
  pipeline_template_files = fileset(local.pipeline_template_files_directory_path, "**/*.yaml")

  target_folder_name = ".pipelines"

  starter_module_config = var.iac_type == "bicep" ? jsondecode(file("${var.module_folder_path}/${var.bicep_config_file_path}")).starter_modules[var.starter_module_name] : null
  script_files_all = var.iac_type == "bicep" ? local.starter_module_config.deployment_files : []
  destroy_script_path = var.iac_type == "bicep" ? local.starter_module_config.destroy_script_path : ""

  networking_type  = var.iac_type == "bicep" ? jsondecode(file("${var.module_folder_path}/${var.bicep_parameters_file_path}")).NETWORK_TYPE : ""
  script_files = var.iac_type == "bicep" ? { for script_file in local.script_files_all : format("%03d", script_file.order) => {
    name                       = lower(replace(replace(replace(replace(script_file.displayName, " ", "_"), "(", ""), ")", ""), "-", "_"))
    displayName                = script_file.displayName
    templateFilePath           = script_file.templateFilePath
    templateParametersFilePath = script_file.templateParametersFilePath
    managementGroupIdVariable  = try("$(${script_file.managementGroupId})", "")
    subscriptionIdVariable     = try("$(${script_file.subscriptionId})", "")
    resourceGroupNameVariable  = try("$(${script_file.resourceGroupName})", "")
    deploymentType             = script_file.deploymentType
    firstRunWhatIf             = script_file.firstRunWhatIf
  } if try(script_file.networkType, "") == "" || try(script_file.networkType, "") == local.networking_type } : {}

  cicd_files = { for pipeline_file in local.pipeline_files : "${local.target_folder_name}/${pipeline_file}" =>
    {
      content = templatefile("${local.pipeline_files_directory_path}/${pipeline_file}", {
        project_name              = var.azure_devops_project_name
        repository_name_templates = local.repository_name_templates
        ci_template_path          = local.ci_file_name
        cd_template_path          = local.cd_file_name
        script_files              = local.script_files
      })
    }
  }

  cicd_template_files = { for pipeline_template_file in local.pipeline_template_files : pipeline_template_file =>
    {
      content = templatefile("${local.pipeline_template_files_directory_path}/${pipeline_template_file}", {
        agent_pool_configuration      = local.agent_pool_configuration
        environment_name_plan         = local.resource_names.version_control_system_environment_plan
        environment_name_apply        = local.resource_names.version_control_system_environment_apply
        variable_group_name           = local.resource_names.version_control_system_variable_group
        project_name                  = var.azure_devops_project_name
        repository_name_templates     = local.repository_name_templates
        service_connection_name_plan  = local.resource_names.version_control_system_service_connection_plan
        service_connection_name_apply = local.resource_names.version_control_system_service_connection_apply
        self_hosted_agent             = var.use_self_hosted_agents
        script_files                  = local.script_files
        destroy_script_path           = local.destroy_script_path
      })
    }
  }

  module_files = { for key, value in module.files.files : key =>
    {
      content = try(replace((file(value.path)), "# backend \"azurerm\" {}", "backend \"azurerm\" {}"), "unsupported_file_type")
    }
  }
  module_files_supported    = { for key, value in local.module_files : key => value if value.content != "unsupported_file_type" && !endswith(key, "-cache.json") }
  repository_files          = merge(local.cicd_files, local.module_files_supported, var.use_separate_repository_for_pipeline_templates ? {} : local.cicd_template_files)
  template_repository_files = var.use_separate_repository_for_pipeline_templates ? local.cicd_template_files : {}
}
