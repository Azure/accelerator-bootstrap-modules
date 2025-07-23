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

locals {
  team_id        = var.create_team ? github_team.alz[0].id : var.existing_team_name == null ? null : data.github_team.alz[0].id
  approver_count = var.create_team ? length(local.approvers) : var.existing_team_name == null ? 0 : (data.github_team.alz[0].members)
}

data "github_team" "alz" {
  count = var.create_team ? 0 : 1
  slug  = var.existing_team_name
}

resource "github_team" "alz" {
  count       = var.create_team ? 1 : 0
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
  for_each = var.create_team ? { for approver in local.approvers : approver.login => approver } : {}
  team_id  = local.team_id
  username = each.value.login
  role     = "member"
}

resource "github_team_repository" "alz" {
  team_id    = local.team_id
  repository = github_repository.alz.name
  permission = "push"
}
