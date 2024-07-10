variable "github_personal_access_token" {
  description = "Personal access token for GitHub|2"
  type        = string
  sensitive   = true
}

variable "github_organization_name" {
  description = "The name of your GitHub organization. This is the section of the url after 'github.com'. E.g. enter 'my-org' for 'https://github.com/my-org'|3"
  type        = string
}

variable "use_separate_repository_for_templates" {
  description = "Controls whether to use a separate repository to store action templates. This is an extra layer of security to ensure that the azure credentials can only be leveraged for the specified workload|4"
  type        = bool
  default     = true
}

variable "bootstrap_location" {
  description = "Azure Deployment location for the bootstrap resources (e.g. storage account, identities, etc)|4|azure_location"
  type        = string
}

variable "bootstrap_subscription_id" {
  description = "Azure Subscription ID for the bootstrap resources (e.g. storage account, identities, etc). Leave empty to use the az login subscription|6|azure_subscription_id"
  type        = string
  default     = ""
}

variable "service_name" {
  description = "Used to build up the default resource names (e.g. rg-<service_name>-mgmt-uksouth-001)|7|azure_name_section"
  type        = string
  default     = "alz"
}

variable "environment_name" {
  description = "Used to build up the default resource names (e.g. rg-alz-<environment_name>-uksouth-001)|8|azure_name_section"
  type        = string
  default     = "mgmt"
}

variable "postfix_number" {
  description = "Used to build up the default resource names (e.g. rg-alz-mgmt-uksouth-<postfix_number>)|9|number"
  type        = number
  default     = 1
}

variable "use_self_hosted_runners" {
  description = "Controls whether to use self-hosted runners for the actions|10"
  type        = bool
  default     = true
}

variable "github_runners_personal_access_token" {
  description = "Personal access token for GitHub self-hosted runners (the token requires the 'repo' scope and should not expire). Only required if 'use_self_hosted_runners' is 'true'|11"
  type        = string
  sensitive   = true
  default     = ""
}

variable "use_private_networking" {
  description = "Controls whether to use private networking for the runner to storage account communication|11"
  type        = bool
  default     = true
}

variable "use_runner_group" {
  description = "Controls whether to use a runner group. This is only relevant if using a GitHub Enterprise licensed organization|12"
  type        = bool
  default     = true
}

variable "allow_storage_access_from_my_ip" {
  description = "Allow access to the storage account from the current IP address. We recommend this is kept off for security|13"
  type        = bool
  default     = false
}

variable "apply_approvers" {
  description = "Apply stage approvers to the action / pipeline, must be a list of SPNs separate by a comma (e.g. abcdef@microsoft.com,ghijklm@microsoft.com)|14"
  type        = list(string)
  default     = []
}

variable "create_branch_policies" {
  description = "Controls whether to create branch policies for the repositories|15"
  type        = bool
  default     = true
}
