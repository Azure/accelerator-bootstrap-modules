locals {
  workflows = {
    ci = {
      workflow_file_name = ".github/workflows/ci.yaml"
      environment_user_assigned_managed_identity_mappings = [{
        environment_key                    = "plan"
        user_assigned_managed_identity_key = "plan"
      }]
    }
    cd = {
      workflow_file_name = ".github/workflows/cd.yaml"
      environment_user_assigned_managed_identity_mappings = [{
        environment_key                    = "plan"
        user_assigned_managed_identity_key = "plan"
        },
        {
          environment_key                    = "apply"
          user_assigned_managed_identity_key = "apply"
      }]
    }
  }
}
