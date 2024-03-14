variable "additional_files" {
  description = "Additional files to upload to the repository. This must be specified as a comma-separated list of absolute file paths (e.g. c:\\config\\config.yaml or /home/user/config/config.yaml)"
  type        = list(string)
  default     = []
}

variable "built_in_configurartion_file_name" {
  description = "The name of the built-in configuration file"
  type        = string
  default     = "config.yaml"
}

variable "module_folder_path_relative" {
  description = "Whether the module folder path is relative to the bootstrap module"
  type        = bool
  default     = true
}

variable "resource_names" {
  type        = map(string)
  description = "Overrides for resource names"
}

variable "federated_credentials" {
  description = "Federated credentials for other version control systems"
  type = map(object({
    user_assigned_managed_identity_key = string
    federated_credential_subject       = string
    federated_credential_issuer        = string
    federated_credential_name          = string
  }))
  default = {}
}

variable "default_target_directory" {
  description = "The default target directory to create the landing zone files in"
  type        = string
  default     = "../../../local"
}
