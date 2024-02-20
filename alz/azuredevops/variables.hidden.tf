



variable "additional_files" {
  description = "Additional files to upload to the repository. This must be specified as a comma-separated list of absolute file paths (e.g. c:\\config\\config.yaml or /home/user/config/config.yaml)"
  type        = list(string)
  default     = []
}

variable "agent_container_image" {
  description = "The container image to use for Azure DevOps Agents"
  type        = string
}

variable "agent_container_cpu" {
  description = "The container cpu default"
  type        = number
  default     = 2
}

variable "agent_container_memory" {
  description = "The container memory default"
  type        = number
  default     = 4
}

variable "agent_container_cpu_max" {
  description = "The container cpu default"
  type        = number
  default     = 2
}

variable "agent_container_memory_max" {
  description = "The container memory default"
  type        = number
  default     = 4
}



variable "built_in_configurartion_file_name" {
  description = "The name of the built-in configuration file"
  type        = string
  default     = "config.yaml"
}

variable "module_folder_path" {
  description = "The folder for the starter modules"
  type        = string
}

variable "module_folder_path_relative" {
  description = "Whether the module folder path is relative to the bootstrap module"
  type        = bool
  default     = true
}

variable "pipeline_folder_path" {
  description = "The folder for the pipelines"
  type        = string
}

variable "pipeline_folder_path_relative" {
  description = "Whether the pipeline folder path is relative to the bootstrap module"
  type        = bool
  default     = true
}

variable "pipeline_files" {
  description = "The pipeline files to upload to the repository"
  type = map(object({
    pipeline_name           = string
    file_path               = string
    target_path             = string
    environment_keys        = list(string)
    service_connection_keys = list(string)
    agent_pool_keys         = list(string)
  }))
}

variable "pipeline_template_files" {
  description = "The pipeline template files to upload to the repository"
  type = map(object({
    file_path   = string
    target_path = string
  }))
}

variable "resource_names" {
  type        = map(string)
  description = "Overrides for resource names"
}

variable "agent_name_environment_variable" {
  description = "The agent name environment variable supplied to the container"
  type        = string
  default     = "AZP_AGENT_NAME"
}

variable "agent_pool_environment_variable" {
  description = "The agent pool environment variable supplied to the container"
  type        = string
  default     = "AZP_POOL"
}

variable "agent_organization_environment_variable" {
  description = "The agent organization environment variable supplied to the container"
  type        = string
  default     = "AZP_URL"
}

variable "agent_token_environment_variable" {
  description = "The agent token environment variable supplied to the container"
  type        = string
  default     = "AZP_TOKEN"
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
