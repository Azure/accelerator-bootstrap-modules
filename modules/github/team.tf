locals {
  approvers = [for user in data.github_organization.this.users : {
    login = user.login
    email = user.email
  } if contains(values(var.approvers), user.email)]
  invalid_approvers = setsubtract(values(var.approvers), local.approvers.*.email)
}

resource "github_team" "alz" {
  name        = var.team_name
  description = "Approvers for the Landing Zone Terraform Apply"
  privacy     = "closed"
}

resource "github_team_membership" "alz" {
  for_each = { for approver in local.approvers : approver.login => approver }
  team_id  = github_team.alz.id
  username = each.value.login
  role     = "member"

  lifecycle {
    precondition {
      condition     = length(local.invalid_approvers) == 0
      error_message = "At least one approver has not been supplied with a valid email. Invalid approvers: ${join(", ", local.invalid_approvers)}"
    }
  }
}

resource "github_team_repository" "alz" {
  team_id    = github_team.alz.id
  repository = github_repository.alz.name
  permission = "push"
}
