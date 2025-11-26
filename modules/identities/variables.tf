variable "resource_group_name" {
  type        = string
  description = "Name of the resource group for bootstrap identities"
}

variable "location" {
  type        = string
  description = "Azure location for resources"
}

variable "managed_identities" {
  type        = map(string)
  description = "Map of managed identities to create. Key is the logical name (e.g., 'plan', 'apply'), value is the resource name."
}

variable "federated_credentials" {
  type = map(object({
    user_assigned_managed_identity_key = string
    federated_credential_subject       = string
    federated_credential_issuer        = string
    federated_credential_name          = string
    audience                           = list(string)
  }))
  default     = {}
  description = "Federated identity credentials for workload identity federation. Typically used with Azure DevOps or GitHub Actions."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}
