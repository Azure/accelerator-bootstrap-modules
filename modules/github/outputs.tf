output "subjects" {
  description = "Map of OIDC subject claims for each workflow and environment combination. These subject claims are used to configure federated credentials in Azure, establishing trust between GitHub Actions and Azure managed identities for keyless authentication."
  value       = local.oidc_subjects
}

output "issuer" {
  description = "OIDC issuer URL for GitHub Actions. Used to configure federated credentials in Azure. For public GitHub: https://token.actions.githubusercontent.com. For GitHub Enterprise: https://token.actions.<domain>."
  value       = var.domain_name == "github.com" ? "https://token.actions.githubusercontent.com" : "https://token.actions.${var.domain_name}"
}

output "organization_users" {
  description = "List of all user accounts in the GitHub organization. Can be used for validation, reporting, or identifying available approvers."
  value       = data.github_organization.alz.users
}

output "runner_group_name" {
  description = "Name of the runner group configured for workflows. Returns the custom runner group name for Enterprise orgs or the default runner group name for standard plans."
  value       = local.runner_group_name
}

output "organization_plan" {
  description = "GitHub organization plan type (free, team, enterprise). Used to determine available features like runner groups, advanced security, and team-based access controls."
  value       = data.github_organization.alz.plan
}

output "repository_names" {
  description = "Names of the created GitHub repositories. Includes the main module repository and the templates repository (if created). Used for reference and validation purposes."
  value = {
    module    = github_repository.alz.name
    templates = var.use_template_repository ? github_repository.alz_templates[0].name : ""
  }
}
