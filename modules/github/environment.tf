resource "github_repository_environment" "alz" {
  depends_on  = [github_team_repository.alz]
  for_each    = var.environments
  environment = each.value
  repository  = github_repository.alz.name

  dynamic "reviewers" {
    for_each = each.key == local.apply_key && local.approver_count > 0 ? [1] : []
    content {
      teams = [
        local.team_id
      ]
    }
  }

  dynamic "deployment_branch_policy" {
    for_each = each.key == local.apply_key ? [1] : []
    content {
      protected_branches     = true
      custom_branch_policies = false
    }
  }
}
