variable "use_legacy_organization_url" {
  description = <<-EOT
    **(Required)** Whether to use the legacy Azure DevOps organization URL format.

    Set to true for <organization>.visualstudio.com format (legacy).
    Set to false for dev.azure.com/<organization> format (modern).
    Required for older organizations that haven't migrated to the new URL structure.
  EOT
  type        = bool
}

variable "organization_name" {
  description = <<-EOT
    **(Required)** Name of the Azure DevOps organization where resources will be created.

    This is the organization segment in the URL.
    Example: 'my-org' from dev.azure.com/my-org
  EOT
  type        = string
}

variable "create_project" {
  description = <<-EOT
    **(Required)** Whether to create a new Azure DevOps project.

    Set to true to create a new project with the specified name.
    Set to false to use an existing project.
  EOT
  type        = bool
}

variable "project_name" {
  description = <<-EOT
    **(Required)** Name of the Azure DevOps project for Azure Landing Zones deployment.

    This project will contain repositories, pipelines, and other deployment resources.
    Used for both new and existing projects depending on create_project setting.
  EOT
  type        = string
}

variable "environments" {
  description = <<-EOT
    **(Required)** Map of Azure DevOps environments with their associated service connections.

    Each environment (e.g., 'plan', 'apply') includes protection settings and OIDC-based
    service connection configuration for secure Azure authentication.

    Map configuration where:
    - **Key**: Environment identifier
    - **Value**: Object containing:
      - `environment_name` (string) - Display name for the environment
      - `service_connection_name` (string) - Name of the Azure service connection
      - `service_connection_required_templates` (list(string)) - List of required template repositories
  EOT
  type = map(object({
    environment_name                      = string
    service_connection_name               = string
    service_connection_required_templates = list(string)
  }))
}

variable "pipelines" {
  description = <<-EOT
    **(Required)** Map of Azure Pipelines to create for CI/CD workflows.

    Each pipeline definition specifies the YAML file location, required environments
    for approvals, and service connections for Azure authentication.

    Map configuration where:
    - **Key**: Pipeline identifier
    - **Value**: Object containing:
      - `pipeline_name` (string) - Display name for the pipeline
      - `pipeline_file_name` (string) - Path to the YAML pipeline file in the repository
      - `environment_keys` (list(string)) - List of environment keys required for approvals
      - `service_connection_keys` (list(string)) - List of service connection keys for Azure access
  EOT
  type = map(object({
    pipeline_name           = string
    pipeline_file_name      = string
    environment_keys        = list(string)
    service_connection_keys = list(string)
  }))
}

variable "managed_identity_client_ids" {
  description = <<-EOT
    **(Required)** Map of user-assigned managed identity keys to their client IDs.

    Used to configure OIDC-based service connections for keyless authentication
    between Azure DevOps and Azure.

    Example:
    ```
    {
      plan  = "00000000-0000-0000-0000-000000000000"
      apply = "11111111-1111-1111-1111-111111111111"
    }
    ```
  EOT
  type        = map(string)
}

variable "repository_name" {
  description = <<-EOT
    **(Required)** Name of the Azure DevOps repository for Azure Landing Zones deployment code.

    This repository will contain the generated Terraform or Bicep configuration files
    and pipeline definitions.
  EOT
  type        = string
}

variable "repository_files" {
  description = <<-EOT
    **(Required)** Map of files to create in the main repository.

    Each entry specifies the file path (key) and content (value).
    Includes configuration files, IaC code, and pipeline YAML files for the Azure Landing Zones deployment.

    Map configuration where:
    - **Key**: File path relative to repository root
    - **Value**: Object containing:
      - `content` (string) - File contents
  EOT
  type = map(object({
    content = string
  }))
}

variable "template_repository_files" {
  description = <<-EOT
    **(Required)** Map of files to create in the separate templates repository (if used).

    Contains reusable pipeline templates that can be referenced from the main repository,
    providing an additional security boundary for pipeline definitions.

    Map configuration where:
    - **Key**: File path relative to repository root
    - **Value**: Object containing:
      - `content` (string) - File contents
  EOT
  type = map(object({
    content = string
  }))
}

variable "variable_group_name" {
  description = <<-EOT
    **(Required)** Name of the Azure Pipelines variable group to create.

    This variable group stores shared configuration values used across pipelines,
    such as subscription IDs, resource names, and deployment settings.
  EOT
  type        = string
}

variable "azure_tenant_id" {
  description = <<-EOT
    **(Required)** Azure Active Directory (Entra ID) tenant ID where Azure Landing Zones will be deployed.

    Used for configuring service connections and authentication.
    Must be a valid GUID format.
  EOT
  type        = string
}

variable "azure_subscription_id" {
  description = <<-EOT
    **(Required)** Azure subscription ID for the bootstrap resources.

    This subscription hosts the CI/CD infrastructure including storage account and managed identities.
    Referenced in pipeline variables and must be a valid GUID format.
  EOT
  type        = string
}

variable "azure_subscription_name" {
  description = <<-EOT
    **(Required)** Human-readable name of the Azure subscription containing bootstrap resources.

    Used in service connection configuration and for pipeline variable documentation.
  EOT
  type        = string
}

variable "backend_azure_resource_group_name" {
  description = <<-EOT
    **(Required)** Name of the Azure resource group containing the Terraform state storage account.

    Referenced in pipeline variables and backend configuration for state management.
  EOT
  type        = string
}

variable "backend_azure_storage_account_name" {
  description = <<-EOT
    **(Required)** Name of the Azure storage account used for storing Terraform state files.

    Referenced in pipeline variables to configure Terraform backend for remote state storage.
  EOT
  type        = string
}

variable "backend_azure_storage_account_container_name" {
  description = <<-EOT
    **(Required)** Name of the blob container that stores Terraform state files.

    Referenced in pipeline variables for backend configuration.
    Located within the storage account specified by backend_azure_storage_account_name.
  EOT
  type        = string
}

variable "approvers" {
  description = <<-EOT
    **(Required)** List of Azure DevOps user principal names (emails) authorized to approve deployments.

    These users must approve before pipeline stages targeting protected environments can execute.

    Example:
    ```
    [
      "user1@contoso.com",
      "user2@contoso.com"
    ]
    ```
  EOT
  type        = list(string)
}

variable "group_name" {
  description = <<-EOT
    **(Required)** Name of the Azure DevOps group to create for approvers.

    This group is configured as the approver for protected environments,
    providing centralized approval management.
  EOT
  type        = string
}

variable "use_template_repository" {
  description = <<-EOT
    **(Required)** Whether to create a separate repository for pipeline templates.

    When true, creates an additional repository for reusable pipeline templates,
    enhancing security by separating pipeline logic from deployment code.
  EOT
  type        = bool
}

variable "repository_name_templates" {
  description = <<-EOT
    **(Required)** Name of the separate repository for pipeline templates.

    Used only when use_template_repository is true.
    This repository contains reusable YAML templates referenced by pipelines in the main repository.
  EOT
  type        = string
}

variable "agent_pool_name" {
  description = <<-EOT
    **(Required)** Name of the Azure DevOps agent pool for running pipeline jobs.

    When using self-hosted agents, this pool must contain registered agents with appropriate capabilities.
    For Microsoft-hosted agents, use 'Azure Pipelines'.
  EOT
  type        = string
}

variable "use_self_hosted_agents" {
  description = <<-EOT
    **(Required)** Whether pipelines use self-hosted agents or Microsoft-hosted agents.

    When true, requires an agent pool with registered self-hosted agents (e.g., Azure Container Instances).
    When false, uses Microsoft-hosted agents from Azure Pipelines.
  EOT
  type        = bool
}

variable "create_branch_policies" {
  description = <<-EOT
    **(Required)** Whether to create branch protection policies on the main branch.

    When enabled, enforces code review requirements, build validation,
    and other quality gates before merging changes.
  EOT
  type        = bool
}

variable "create_variable_group" {
  description = <<-EOT
    **(Required)** Whether to create an Azure Pipelines variable group for shared configuration.

    When true, creates a variable group containing backend and subscription details
    used across multiple pipelines.
  EOT
  type        = bool
}