variable "iac_type" {
  description = "The type of infrastructure as code to use for the deployment. (e.g. 'terraform' or 'bicep')"
  type        = string
}

variable "module_folder_path" {
  description = "The folder for the starter modules"
  type        = string
}

variable "pipeline_folder_path" {
  description = "The folder for the pipelines"
  type        = string
}

variable "root_parent_management_group_id" {
  description = "The root parent management group display name. This will default to 'Tenant Root Group' if not supplied"
  type        = string
}

variable "subscription_id_connectivity" {
  description = "The identifier of the Connectivity Subscription"
  type        = string
}

variable "subscription_id_identity" {
  description = "The identifier of the Identity Subscription"
  type        = string
}

variable "subscription_id_management" {
  description = "The identifier of the Management Subscription"
  type        = string
}

variable "configuration_file_path" {
  description = "The name of the configuration file"
  type        = string
  default     = ""
}
