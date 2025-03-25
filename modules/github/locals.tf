locals {
  apply_key = "apply"
}

locals {
  free_plan       = "free"
  enterprise_plan = "enterprise"
}

locals {
  use_runner_group = var.use_runner_group && data.github_organization.alz.plan == local.enterprise_plan && var.use_self_hosted_runners
}

locals {
  primary_approver     = length(var.approvers) > 0 ? var.approvers[0] : ""
  default_commit_email = coalesce(local.primary_approver, "demo@microsoft.com")
}

locals {
  repository_name_templates = var.use_template_repository ? var.repository_name_templates : var.repository_name
  template_claim_structure  = "${var.organization_name}/${local.repository_name_templates}/%s@refs/heads/main"

  oidc_subjects_flattened = flatten([for key, value in var.workflows : [
    for environment_user_assigned_managed_identity_mapping in value.environment_user_assigned_managed_identity_mappings :
    {
      subject_key                        = "${key}-${environment_user_assigned_managed_identity_mapping.user_assigned_managed_identity_key}"
      user_assigned_managed_identity_key = environment_user_assigned_managed_identity_mapping.user_assigned_managed_identity_key
      subject                            = "repo:${var.organization_name}/${var.repository_name}:environment:${var.environments[environment_user_assigned_managed_identity_mapping.environment_key]}:job_workflow_ref:${format(local.template_claim_structure, value.workflow_file_name)}"
    }
    ]
  ])

  oidc_subjects = { for oidc_subject in local.oidc_subjects_flattened : oidc_subject.subject_key => {
    user_assigned_managed_identity_key = oidc_subject.user_assigned_managed_identity_key
    subject                            = oidc_subject.subject
  } }
}

locals {
  runner_group_name = local.use_runner_group ? github_actions_runner_group.alz[0].name : var.default_runner_group_name
}
