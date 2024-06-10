locals {
  pipelines = {
    ci = {
      pipeline_name      = local.resource_names.version_control_system_pipeline_name_ci
      pipeline_file_name = "${local.target_folder_name}/${local.ci_file_name}"
      environment_keys = [
        local.plan_key
      ]
      service_connection_keys = [
        local.plan_key
      ]
    }
    cd = {
      pipeline_name      = local.resource_names.version_control_system_pipeline_name_cd
      pipeline_file_name = "${local.target_folder_name}/${local.cd_file_name}"
      environment_keys = [
        local.plan_key,
        local.apply_key
      ]
      service_connection_keys = [
        local.plan_key,
        local.apply_key
      ]
    }
  }
}
