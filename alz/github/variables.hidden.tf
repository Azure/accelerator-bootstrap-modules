variable "built_in_configurartion_file_name" {
  description = "The name of the built-in configuration file"
  type        = string
  default     = "config.yaml"
}

variable "module_folder_path_relative" {
  description = "Whether the module folder path is relative to the bootstrap module"
  type        = bool
  default     = false
}

variable "resource_names" {
  type        = map(string)
  description = "Overrides for resource names"
}

variable "runner_container_image_repository" {
  description = "The container image repository to use for GitHub Runner"
  type        = string
}

variable "runner_container_image_tag" {
  description = "The container image tag to use for GitHub Runner"
  type        = string
}

variable "runner_container_image_folder" {
  description = "The folder containing the Dockerfile for the container image"
  type        = string
}

variable "runner_container_image_dockerfile" {
  description = "The Dockerfile to use for the container image"
  type        = string
}

variable "runner_container_cpu" {
  description = "The container cpu default"
  type        = number
  default     = 2
}

variable "runner_container_memory" {
  description = "The container memory default"
  type        = number
  default     = 4
}

variable "runner_container_cpu_max" {
  description = "The container cpu default"
  type        = number
  default     = 2
}

variable "runner_container_memory_max" {
  description = "The container memory default"
  type        = number
  default     = 4
}

variable "runner_name_environment_variable" {
  description = "The runner name environment variable supplied to the container"
  type        = string
  default     = "GH_RUNNER_NAME"
}

variable "runner_group_environment_variable" {
  description = "The runner group environment variable supplied to the container"
  type        = string
  default     = "GH_RUNNER_GROUP"
}

variable "runner_organization_environment_variable" {
  description = "The runner url environment variable supplied to the container"
  type        = string
  default     = "GH_RUNNER_URL"
}

variable "runner_token_environment_variable" {
  description = "The runner token environment variable supplied to the container"
  type        = string
  default     = "GH_RUNNER_TOKEN"
}

variable "default_runner_group_name" {
  description = "The default runner group name for unlicenses orgs"
  type        = string
  default     = "Default"
}

variable "virtual_network_address_space" {
  type        = string
  description = "The address space for the virtual network"
  default     = "10.0.0.0/24"
}

variable "virtual_network_subnet_address_prefix_container_instances" {
  type        = string
  description = "Address prefix for the virtual network subnet"
  default     = "10.0.0.0/26"
}

variable "virtual_network_subnet_address_prefix_storage" {
  type        = string
  description = "Address prefix for the virtual network subnet"
  default     = "10.0.0.64/26"
}

variable "additional_files" {
  description = "Additional files to upload to the repository. This must be specified as a comma-separated list of absolute file paths (e.g. c:\\config\\config.yaml or /home/user/config/config.yaml)"
  type        = list(string)
  default     = []
}

variable "storage_account_replication_type" {
  description = "Controls the redundancy for the storage account"
  type        = string
  default     = "GZRS"
  validation {
    condition     = var.storage_account_replication_type == "ZRS" || var.storage_account_replication_type == "GZRS" || var.storage_account_replication_type == "RAGZRS"
    error_message = "Invalid storage account replication type. Valid values are ZRS, GZRS and RAGZRS."
  }
}
