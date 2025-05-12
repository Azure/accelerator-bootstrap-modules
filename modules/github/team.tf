locals {
  approvers_by_email = [for approver in var.approvers : approver if strcontains(approver, "@")]
  approvers_by_login = [for approver in var.approvers : approver if !strcontains(approver, "@")]

  users_by_email = [for user in data.github_organization.alz.users : {
    login = user.login
    email = user.email
  } if contains(local.approvers_by_email, user.email)]

  users_by_login = [for user in data.github_organization.alz.users : {
    login = user.login
    email = user.email
  } if contains(local.approvers_by_login, user.login)]

  approvers = concat(local.users_by_email, local.users_by_login)

  invalid_approvers_by_email = setsubtract(local.approvers_by_email, local.users_by_email[*].email)
  invalid_approvers_by_login = setsubtract(local.approvers_by_login, local.users_by_login[*].login)

  invalid_approvers = setunion(local.invalid_approvers_by_email, local.invalid_approvers_by_login)
}

resource "github_team" "alz" {
  name        = var.team_name
  description = "Approvers for the Landing Zone Terraform Apply"
  privacy     = "closed"

  lifecycle {
    precondition {
      condition     = length(local.invalid_approvers) == 0
      error_message = "At least one approver has not been supplied with a valid email or username. Invalid approvers by email: ${join(", ", local.invalid_approvers_by_email)}. Invalid approvers by username: ${join(", ", local.invalid_approvers_by_login)}."
    }
  }
}

resource "github_team_membership" "alz" {
  for_each = { for approver in local.approvers : approver.login => approver }
  team_id  = github_team.alz.id
  username = each.value.login
  role     = "member"
}

resource "github_team_repository" "alz" {
  team_id    = github_team.alz.id
  repository = github_repository.alz.name
  permission = "push"
}
