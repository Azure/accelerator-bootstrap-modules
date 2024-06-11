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

variable "built_in_configurartion_file_name" {
  description = "Built-in configuration file name"
  type        = string
  default     = "config.yaml"
}
