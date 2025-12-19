variable "domain_name" {
  description = <<-EOT
    **(Required)** Domain name of the GitHub instance.

    For public GitHub: 'github.com'
    For GitHub Enterprise Server: your enterprise domain (e.g., 'github.contoso.com')

    Used for constructing API endpoints and OIDC issuer URLs.
  EOT
  type        = string
}

variable "organization_name" {
  description = <<-EOT
    **(Required)** Name of the GitHub organization where repositories will be created.

    This is the organization segment in the URL (e.g., 'my-org' from github.com/my-org).
    Used for Azure Landing Zones deployment.
    Must have appropriate permissions in this organization.
  EOT
  type        = string
}

variable "repository_name" {
  description = <<-EOT
    **(Required)** Name of the GitHub repository to create for Azure Landing Zones deployment code.

    This repository will contain the generated Terraform or Bicep configuration files
    and GitHub Actions workflow definitions.
  EOT
  type        = string
}

variable "repository_files" {
  description = <<-EOT
    **(Required)** Map of files to create in the main repository.

    Each entry specifies:
    - **Key**: File path in the repository
    - **Value**: Object containing:
      - `content` (string) - File content

    Includes configuration files, IaC code, and workflow YAML files for the Azure Landing Zones deployment.
  EOT
  type = map(object({
    content = string
  }))
}

variable "template_repository_files" {
  description = <<-EOT
    **(Required)** Map of files to create in the separate templates repository (if used).

    Each entry specifies:
    - **Key**: File path in the repository
    - **Value**: Object containing:
      - `content` (string) - File content

    Contains reusable workflow templates that can be referenced from the main repository,
    providing an additional security boundary for workflow definitions.
  EOT
  type = map(object({
    content = string
  }))
}

variable "environments" {
  description = <<-EOT
    **(Required)** Map of GitHub environment names to create for deployment protection.

    Each environment (e.g., 'plan', 'apply') can have protection rules, required reviewers,
    and deployment branches configured.

    - **Key**: Internal reference identifier
    - **Value**: Environment name
  EOT
  type        = map(string)
}

variable "managed_identity_client_ids" {
  description = <<-EOT
    **(Required)** Map of user-assigned managed identity keys to their client IDs.

    Used to configure OIDC-based authentication in GitHub Actions workflows
    for keyless authentication to Azure.

    - **Key**: Managed identity reference key (e.g., 'plan', 'apply')
    - **Value**: Azure managed identity client ID (GUID)
  EOT
  type        = map(string)
}

variable "azure_tenant_id" {
  description = <<-EOT
    **(Required)** Azure Active Directory (Entra ID) tenant ID where Azure Landing Zones will be deployed.

    Used for configuring OIDC authentication in GitHub Actions workflows.
    Must be a valid GUID format.
  EOT
  type        = string
}

variable "azure_subscription_id" {
  description = <<-EOT
    **(Required)** Azure subscription ID for the bootstrap resources.

    This subscription hosts the CI/CD infrastructure (storage account, managed identities)
    and is referenced in workflow variables and secrets.
  EOT
  type        = string
}

variable "backend_azure_resource_group_name" {
  description = <<-EOT
    **(Required)** Name of the Azure resource group containing the Terraform state storage account.

    Referenced in workflow environment variables for Terraform backend configuration.
  EOT
  type        = string
}

variable "backend_azure_storage_account_name" {
  description = <<-EOT
    **(Required)** Name of the Azure storage account used for storing Terraform state files.

    Referenced in workflow environment variables to configure Terraform backend
    for remote state storage.
  EOT
  type        = string
}

variable "backend_azure_storage_account_container_name" {
  description = <<-EOT
    **(Required)** Name of the blob container within the storage account that stores Terraform state files.

    Referenced in workflow environment variables for backend configuration.
  EOT
  type        = string
}

variable "approvers" {
  description = <<-EOT
    **(Required)** List of GitHub usernames who are authorized to approve deployments in protected environments.

    These users must approve workflow runs before deployment jobs targeting
    production environments can execute.
  EOT
  type        = list(string)
}

variable "create_team" {
  description = <<-EOT
    **(Required)** Controls whether to create a new GitHub team for approvers.

    When true: Creates a team with the specified team_name and adds approvers as members
    When false: Uses existing_team_name if provided
  EOT
  type        = bool
}

variable "existing_team_name" {
  description = <<-EOT
    **(Required)** Name of an existing GitHub team to use for environment protection.

    Only used when create_team is false.
    This team should already exist in the organization and contain the appropriate approvers.
  EOT
  type        = string
}

variable "team_name" {
  description = <<-EOT
    **(Required)** Name of the GitHub team to create for deployment approvers.

    Only used when create_team is true.
    This team is configured as a required reviewer for protected environments.
  EOT
  type        = string
}

variable "use_template_repository" {
  description = <<-EOT
    **(Required)** Controls whether to create a separate repository for workflow templates.

    When true: Creates an additional repository for reusable workflow templates,
    enhancing security by separating workflow logic from deployment code and limiting credential access.
  EOT
  type        = bool
}

variable "repository_name_templates" {
  description = <<-EOT
    **(Required)** Name of the separate repository for workflow templates.

    Only used when use_template_repository is true.
    This repository contains reusable YAML templates referenced by workflows in the main repository.
  EOT
  type        = string
}

variable "workflows" {
  description = <<-EOT
    **(Required)** Map of GitHub Actions workflows to create for CI/CD.

    Each workflow definition specifies:
    - **Key**: Workflow identifier
    - **Value**: Object containing:
      - `workflow_file_name` (string) - YAML file name for the workflow
      - `environment_user_assigned_managed_identity_mappings` (list) - List of objects with:
        - `environment_key` (string) - GitHub environment key
        - `user_assigned_managed_identity_key` (string) - Azure managed identity key

    Defines mappings between GitHub environments and Azure managed identities for OIDC authentication.
  EOT
  type = map(object({
    workflow_file_name = string
    environment_user_assigned_managed_identity_mappings = list(object({
      environment_key                    = string
      user_assigned_managed_identity_key = string
    }))
  }))
}

variable "runner_group_name" {
  description = <<-EOT
    **(Required)** Name of the GitHub Actions runner group for self-hosted runners.

    Only applicable for GitHub Enterprise with runner groups enabled.
    Runners must be registered to this group.
  EOT
  type        = string
}

variable "default_runner_group_name" {
  description = <<-EOT
    **(Required)** Default runner group name for organizations without Enterprise licensing.

    Typically 'Default' for standard GitHub plans that don't support custom runner groups.
  EOT
  type        = string
}

variable "use_runner_group" {
  description = <<-EOT
    **(Required)** Controls whether to configure workflows to use a specific runner group.

    Only relevant for GitHub Enterprise organizations.
    When false or for non-Enterprise orgs, uses default runner assignment.
  EOT
  type        = bool
}

variable "use_self_hosted_runners" {
  description = <<-EOT
    **(Required)** Controls whether workflows use self-hosted runners or GitHub-hosted runners.

    When true: Requires self-hosted runners (e.g., Azure Container Instances) registered
    to the organization or runner group
    When false: Uses GitHub-hosted runners
  EOT
  type        = bool
}

variable "create_branch_policies" {
  description = <<-EOT
    **(Required)** Controls whether to create branch protection rules on the default branch.

    When enabled: Enforces code review requirements, status checks, and other quality gates
    before merging changes to the main branch
  EOT
  type        = bool
}

variable "create_storage_account_variables" {
  description = <<-EOT
    **(Required)** Whether to create GitHub Actions variables for Azure storage account details.

    When true: Creates repository-level variables for backend storage configuration
    When false: Assumes variables are managed externally
  EOT
  type        = bool
}