variable "starter_module_folder_path" {
  description = "Starter module folder path"
  type        = string
}

variable "starter_module_folder_path_exclusion" {
  description = "Starter module folder path exclusion"
  type        = string
  default     = ".examples"
}

variable "additional_files" {
  description = "Additional files"
  type        = list(string)
  default     = []
}

variable "configuration_file_path" {
  description = "Configuration file path"
  type        = string
  default     = ""
}

variable "built_in_configuration_file_names" {
  description = "Built-in configuration file name"
  type        = list(string)
  default     = ["config.yaml", "config-hub-and-spoke-vnet.yaml", "config-virtual-wan.yaml"]
}

variable "additional_folders_path" {
  description = "Additional folders"
  type        = list(string)
  default     = []
}
