output "organization_url" {
  value = local.organization_url
}

output "subjects" {
  value = local.oidc_subjects
}

output "issuer" {
  value = "https://token.actions.githubusercontent.com"
}

output "organization_users" {
  value = data.github_organization.alz.users
}

output "runner_group_name" {
  value = local.runner_group_name
}

output "organization_plan" {
  value = data.github_organization.alz.plan
}

output "repository_names" {
  value = {
    module    = github_repository.alz.name
    templates = var.use_template_repository ? github_repository.alz_templates[0].name : ""
  }
}
