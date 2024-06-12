locals {
  agent_pool_configuration  = var.use_self_hosted_agents ? "name: ${local.resource_names.version_control_system_agent_pool}" : "vmImage: ubuntu-latest"
  repository_name_templates = var.use_separate_repository_for_pipeline_templates ? local.resource_names.version_control_system_repository_templates : local.resource_names.version_control_system_repository

  pipeline_files_directory_path          = "${path.module}/pipelines/${var.iac_type}"
  pipeline_template_files_directory_path = "${path.module}/pipelines/${var.iac_type}/templates"

  pipeline_files          = fileset(local.pipeline_files_directory_path, "*.yaml")
  pipeline_template_files = fileset(local.pipeline_template_files_directory_path, "**/*.yaml")

  target_folder_name = ".pipelines"

  cicd_files = { for pipeline_file in local.pipeline_files : "${local.target_folder_name}/${pipeline_file}" =>
    {
      content = templatefile("${local.pipeline_files_directory_path}/${pipeline_file}", {
        project_name              = var.azure_devops_project_name
        repository_name_templates = local.repository_name_templates
        ci_template_path          = local.ci_file_name
        cd_template_path          = local.cd_file_name
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
      })
    }
  }

  module_files = { for key, value in module.files.files : key =>
    {
      content = replace((file(value.path)), "# backend \"azurerm\" {}", "backend \"azurerm\" {}")
    }
  }
  repository_files          = merge(local.cicd_files, local.module_files, var.use_separate_repository_for_pipeline_templates ? {} : local.cicd_template_files)
  template_repository_files = var.use_separate_repository_for_pipeline_templates ? local.cicd_template_files : {}
}
