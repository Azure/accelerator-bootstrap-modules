locals {
  self_hosted_runner_name = local.use_runner_group ? "group: ${local.resource_names.version_control_system_runner_group}" : "self-hosted"
  runner_name             = var.use_self_hosted_runners ? local.self_hosted_runner_name : "ubuntu-latest"
}

locals {
  pipeline_files_directory_path = "${path.module}/actions/terraform"
  pipeline_template_files_directory_path = "${path.module}/actions/terraform/templates"

  pipeline_files = fileset(local.pipeline_files_directory_path, "*.yaml")
  pipeline_template_files = fileset(local.pipeline_template_files_directory_path, "**/*.yaml")

  cicd_files = { for pipeline_file in local.pipeline_files : ".github/workflows/${pipeline_file}" =>
    {
      content = templatefile("${local.pipeline_files_directory_path}/${pipeline_file}", {
        organization_name         = var.github_organization_name
        repository_name_templates = local.resource_names.version_control_system_repository_templates
        ci_template_path          = ".github/workflows/ci.yaml"
        cd_template_path          = ".github/workflows/cd.yaml"
      })
    }
  }

  cicd_template_files = { for pipeline_template_file in local.pipeline_template_files : ".github/workflows/${pipeline_template_file}" =>
    {
      content = templatefile("${local.pipeline_template_files_directory_path}/${pipeline_template_file}", {
        runner_name                                  = local.runner_name
        environment_name_plan                        = local.resource_names.version_control_system_environment_plan
        environment_name_apply                       = local.resource_names.version_control_system_environment_apply
        backend_azure_storage_account_container_name = local.resource_names.storage_container
      })
    }
  }

  module_files = { for key, value in module.files.files : key =>
    {
      content = replace((file(value.path)), "# backend \"azurerm\" {}", "backend \"azurerm\" {}")
    }
  }
  repository_files = merge(local.cicd_files, local.module_files, var.use_separate_repository_for_workflow_templates ? {} : local.cicd_template_files)
  template_repository_files = var.use_separate_repository_for_workflow_templates ? local.cicd_template_files : {}
}
