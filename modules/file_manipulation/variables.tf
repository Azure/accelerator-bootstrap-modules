variable "vcs_type" {
  description = <<-EOT
    **(Required)** Version Control System type that determines which platform-specific file manipulations to apply.

    Valid values:
    - `github` - GitHub Actions
    - `azuredevops` - Azure Pipelines
    - `local` - Local file system deployment

    Affects workflow/pipeline file generation and repository structure.
  EOT
  type        = string
}

variable "use_self_hosted_agents_runners" {
  description = <<-EOT
    **(Optional, default: `null`)** Controls whether to configure generated workflow/pipeline files for self-hosted agents/runners.

    When true, configures jobs to run on self-hosted infrastructure (Azure Container Instances).
    When false or null, uses platform-provided hosted agents.
  EOT
  type        = bool
  default     = null
}

variable "resource_names" {
  description = <<-EOT
    **(Required)** Complete resource names object containing all resolved resource name mappings.

    Contains resource names after template variable substitution.
    Used throughout file manipulation to populate configuration files, scripts, and workflow definitions with actual resource names.
  EOT
  type        = any
}

variable "files" {
  description = <<-EOT
    **(Required)** Map of source files from the starter module to process and manipulate.

    Map where:
    - **Key**: File identifier
    - **Value**: Object containing:
      - `path` (string) - Source path for reading file content

    File manipulation includes variable substitution, path transformation, and content customization based on deployment configuration.
  EOT
  type = map(object({
    path = string
  }))
}

variable "use_separate_repository_for_templates" {
  description = <<-EOT
    **(Optional, default: `null`)** Controls whether to generate files for a separate templates repository.

    When true, splits pipeline/workflow template files into a dedicated repository for enhanced security,
    preventing credential access from the main deployment repository.
    Null value uses platform defaults.
  EOT
  type        = bool
  default     = null
}

variable "iac_type" {
  description = <<-EOT
    **(Required)** Infrastructure as Code framework type that determines which deployment approach and file transformations to apply.

    Valid values:
    - `terraform` - HashiCorp Terraform
    - `bicep` - Azure Bicep with AVM
    - `bicep-classic` - Traditional Bicep deployment

    Affects generated scripts, configuration files, and pipeline stages.
  EOT
  type        = string
}

variable "module_folder_path" {
  description = <<-EOT
    **(Required)** Absolute or relative path to the starter module folder containing source Azure Landing Zones configuration templates and files.

    This path is used to locate and read files for processing and transformation.
  EOT
  type        = string
}

variable "bicep_config_file_path" {
  description = <<-EOT
    **(Required)** Relative path to the Bicep configuration file within the generated repository structure.

    This JSON file contains deployment settings for the Azure Landing Zones Bicep accelerator
    and is referenced in deployment scripts and pipelines.
  EOT
  type        = string
}

variable "starter_module_name" {
  description = <<-EOT
    **(Required)** Name of the Azure Landing Zones starter module being deployed.

    Used for identifying the specific landing zone archetype and for variable substitution in generated files.
    Examples: 'complete', 'hubnetworking', 'sovereign'
  EOT
  type        = string
}

variable "project_or_organization_name" {
  description = <<-EOT
    **(Optional, default: `null`)** Azure DevOps project name or GitHub organization name where the deployment repository is hosted.

    Used for generating correct repository references, URLs, and OIDC subject claims in workflow/pipeline files.
    Null when deploying locally.
  EOT
  type        = string
  default     = null
}

variable "root_module_folder_relative_path" {
  description = <<-EOT
    **(Required)** Relative path from the repository root to the folder containing the main Terraform or Bicep entry point.

    Used in workflow/pipeline files to set the working directory for IaC operations.
    Typically '.' for root-level deployments.
  EOT
  type        = string
}

variable "on_demand_folder_repository" {
  description = <<-EOT
    **(Required)** Git repository URL containing additional on-demand Azure Landing Zones configuration folders.

    Examples: industry-specific templates, custom policies.
    Used in scripts to dynamically fetch supplementary configurations during deployment.
  EOT
  type        = string
}

variable "on_demand_folder_artifact_name" {
  description = <<-EOT
    **(Required)** Branch name or tag in the on-demand folder repository to retrieve.

    Allows pinning to specific versions of supplementary configurations.
    Used in scripts that fetch on-demand folders during deployment.
  EOT
  type        = string
}

variable "bicep_parameters_file_path" {
  description = <<-EOT
    **(Required)** Relative path to the Bicep parameters JSON file containing deployment input values.

    This file is referenced in Bicep deployment scripts and pipelines to provide configuration values
    for the Azure Landing Zones resources.
  EOT
  type        = string
}

variable "ci_template_file_name" {
  description = <<-EOT
    **(Optional, default: `null`)** Filename of the CI (Continuous Integration) template to use for validation and testing stages.

    Only applicable when using a separate templates repository.
    Null uses the default CI template for the selected platform.
  EOT
  type        = string
  default     = null
}

variable "cd_template_file_name" {
  description = <<-EOT
    **(Optional, default: `null`)** Filename of the CD (Continuous Delivery) template to use for deployment stages.

    Only applicable when using a separate templates repository.
    Null uses the default CD template for the selected platform.
  EOT
  type        = string
  default     = null
}

variable "pipeline_target_folder_name" {
  description = <<-EOT
    **(Required)** Target folder name within the repository where workflow/pipeline files will be placed.

    Examples:
    - GitHub Actions: '.github/workflows'
    - Azure Pipelines: '.azure-pipelines' or custom path
    - Local: 'scripts'
  EOT
  type        = string
}

variable "agent_pool_or_runner_configuration" {
  description = <<-EOT
    **(Optional, default: `null`)** YAML configuration snippet for specifying the agent pool (Azure Pipelines) or runner labels (GitHub Actions).

    Defines where CI/CD jobs execute in generated workflow files.
    Null uses platform defaults.
  EOT
  type        = string
  default     = null
}

variable "pipeline_files_directory_path" {
  description = <<-EOT
    **(Required)** Absolute path to the directory containing source pipeline/workflow file templates to process.

    Files from this directory are transformed and copied to the target repository structure.
  EOT
  type        = string
}

variable "pipeline_template_files_directory_path" {
  description = <<-EOT
    **(Optional, default: `null`)** Absolute path to the directory containing reusable pipeline/workflow template files.

    Used when generating a separate templates repository for enhanced pipeline security.
    Null when not using template repository.
  EOT
  type        = string
  default     = null
}

variable "concurrency_value" {
  description = <<-EOT
    **(Optional, default: `null`)** Concurrency control value for preventing parallel executions of the same workflow/pipeline.

    Used in GitHub Actions concurrency groups or Azure Pipelines queue settings.
    Null allows parallel executions.
  EOT
  type        = string
  default     = null
}

variable "terraform_architecture_file_path" {
  description = <<-EOT
    **(Required)** Relative path to the Terraform architecture definition JSON file within the module folder.

    This file defines the structure and components of the Terraform deployment architecture.
    Used for dynamic file manipulation based on architecture specifics.
  EOT
  type        = string
}
