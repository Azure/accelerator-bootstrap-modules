locals {
  approvers = [for user in data.github_organization.alz.users : {
    login = user.login
  } if contains(var.approvers, user.login)]

  invalid_approvers = setsubtract(var.approvers, local.approvers[*].login)
}

locals {
  team_id        = var.create_team ? github_team.alz[0].id : var.existing_team_name == null ? null : data.github_team.alz[0].id
  approver_count = var.create_team ? length(local.approvers) : var.existing_team_name == null ? 0 : length(data.github_team.alz[0].members)
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
      error_message = "At least one approver has not been supplied with a valid GitHub username: ${join(", ", local.invalid_approvers)}."
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
