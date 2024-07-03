locals {
  workflows = {
    ci = {
      workflow_file_name = "${local.target_folder_name}/${local.ci_template_file_name}"
      environment_user_assigned_managed_identity_mappings = [{
        environment_key                    = local.plan_key
        user_assigned_managed_identity_key = local.plan_key
      }]
    }
    cd = {
      workflow_file_name = "${local.target_folder_name}/${local.cd_template_file_name}"
      environment_user_assigned_managed_identity_mappings = [{
        environment_key                    = local.plan_key
        user_assigned_managed_identity_key = local.plan_key
        },
        {
          environment_key                    = local.apply_key
          user_assigned_managed_identity_key = local.apply_key
      }]
    }
  }
}
