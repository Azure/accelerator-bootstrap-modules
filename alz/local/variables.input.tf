variable "target_directory" {
  description = "The target directory to create the landing zone files in. (e.g. 'c:\\landingzones\\my_landing_zone')"
  type        = string
  default     = ""
}

variable "create_bootstrap_resources_in_azure" {
  description = "Whether to create resources in Azure (e.g. resource group, storage account, identities, etc.)"
  type        = bool
  default     = true
}

variable "bootstrap_subscription_id" {
  description = "Azure Subscription ID for the bootstrap resources (e.g. storage account, identities, etc). Leave empty to use the az login subscription|azure_subscription_id"
  type        = string
  default     = ""
}

variable "service_name" {
  description = "Used to build up the default resource names (e.g. rg-<service_name>-mgmt-uksouth-001)|azure_name_section"
  type        = string
  default     = "alz"
}

variable "environment_name" {
  description = "Used to build up the default resource names (e.g. rg-alz-<environment_name>-uksouth-001)|azure_name_section"
  type        = string
  default     = "mgmt"
}

variable "postfix_number" {
  description = "Used to build up the default resource names (e.g. rg-alz-mgmt-uksouth-<postfix_number>)"
  type        = number
  default     = 1
}

variable "grant_permissions_to_current_user" {
  description = "Grant permissions to the current user on the bootstrap resources in addition to the user assinged managed identities."
  type        = bool
  default     = true
}
