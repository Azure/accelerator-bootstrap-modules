variable "vcs_type" {
  description = "Version Control System type (github, azuredevops, local)"
  type        = string
}

variable "use_self_hosted_agents_runners" {
  description = "Whether to use self-hosted agents"
  type        = bool
  default     = null
}

variable "resource_names" {
  description = "Resource names object containing all resource name mappings"
  type        = any
}

variable "files" {
  description = "Map of files to manipulate"
  type = map(object({
    path = string
  }))
}

variable "use_separate_repository_for_templates" {
  description = "Whether to use a separate repository for templates"
  type        = bool
  default     = null
}

variable "iac_type" {
  description = "Infrastructure as Code type (terraform, bicep, bicep-classic)"
  type        = string
}

variable "module_folder_path" {
  description = "Path to the module folder"
  type        = string
}

variable "bicep_config_file_path" {
  description = "Path to the Bicep configuration file"
  type        = string
}

variable "starter_module_name" {
  description = "Name of the starter module"
  type        = string
}

variable "project_or_organization_name" {
  description = "Azure DevOps project o GiHub Organization name"
  type        = string
  default     = null
}

variable "root_module_folder_relative_path" {
  description = "Relative path to the root module folder"
  type        = string
}

variable "on_demand_folder_repository" {
  description = "Repository for on-demand folders"
  type        = string
}

variable "on_demand_folder_artifact_name" {
  description = "Artifact name for on-demand folders"
  type        = string
}

variable "bicep_parameters_file_path" {
  description = "Path to the Bicep parameters file"
  type        = string
}

variable "subscription_ids" {
  description = "Map of subscription IDs by type (management, connectivity, identity, security)"
  type        = map(string)
}

variable "root_parent_management_group_id" {
  description = "Root parent management group ID"
  type        = string
}

variable "ci_template_file_name" {
  description = "CI template file name"
  type        = string
  default     = null
}

variable "cd_template_file_name" {
  description = "CD template file name"
  type        = string
  default     = null
}

variable "pipeline_target_folder_name" {
  description = "Target folder name for pipelines"
  type        = string
}

variable "agent_pool_or_runner_configuration" {
  description = "Agent pool or runner configuration"
  type        = string
  default     = null
}

variable "pipeline_files_directory_path" {
  description = "Directory path for pipeline files"
  type        = string
}

variable "pipeline_template_files_directory_path" {
  description = "Directory path for pipeline template files"
  type        = string
  default     = null
}

variable "concurrency_value" {
  description = "Concurrency value for pipelines"
  type        = string
  default     = null
}