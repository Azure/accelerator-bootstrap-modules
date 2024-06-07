locals {
  pipelines = {
    ci = {
      pipeline_name = local.resource_names.version_control_system_pipeline_name_ci
      pipeline_file_name = "ci.yaml"
      environment_keys = [
        "plan"
      ]
      service_connection_keys = [
        "plan"
      ]
    }
    cd = {
      pipeline_name = local.resource_names.version_control_system_pipeline_name_cd
      pipeline_file_name = "cd.yaml"
      environment_keys = [
        "plan",
        "apply"
      ]
      service_connection_keys = [
        "plan",
        "apply"
      ]
    }
  }
}