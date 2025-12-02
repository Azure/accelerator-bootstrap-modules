variable "starter_module_folder_path" {
  description = <<-EOT
    **(Required)** Absolute or relative path to the Azure Landing Zones starter module folder.

    This directory contains the source configuration files, templates, and examples that will be
    copied and customized for the deployment.
  EOT
  type        = string
}

variable "starter_module_folder_path_exclusion" {
  description = <<-EOT
    **(Optional, default: `".examples"`)** Folder name pattern to exclude from the starter module.

    Files within folders matching this pattern are not included in the generated repository,
    preventing example/test files from being deployed.
  EOT
  type        = string
  default     = ".examples"
}

variable "additional_files" {
  description = <<-EOT
    **(Optional, default: `[]`)** Additional files to include in the deployment.

    Must be specified as a list of absolute file paths to existing files.
    Useful for adding custom configuration files, policies, or organization-specific documentation.

    Examples:
    - Windows: ["c:\\config\\config.yaml", "c:\\scripts\\deploy.ps1"]
    - Linux/Mac: ["/home/user/config/config.yaml", "/home/user/scripts/deploy.sh"]
  EOT
  type        = list(string)
  default     = []
}

variable "configuration_file_path" {
  description = <<-EOT
    **(Optional, default: `""`)** Absolute path to a custom configuration YAML file.

    When specified, this file overrides the built-in configuration files.
    Must be a valid path to a YAML file with ALZ configuration settings.
    Leave empty to use built-in configurations.
  EOT
  type        = string
  default     = ""
}

variable "built_in_configuration_file_names" {
  description = <<-EOT
    **(Optional, default: `["config.yaml", "config-hub-and-spoke-vnet.yaml", "config-virtual-wan.yaml"]`)**
    List of built-in configuration file names to include from the starter module.

    These files provide pre-configured settings for common Azure Landing Zones scenarios.
    Default includes base config and networking topology variants (hub-and-spoke, virtual WAN).
    Files are included if no custom configuration_file_path is specified.
  EOT
  type        = list(string)
  default     = ["config.yaml", "config-hub-and-spoke-vnet.yaml", "config-virtual-wan.yaml"]
}

variable "additional_folders_path" {
  description = <<-EOT
    **(Optional, default: `[]`)** Additional folders to include in the deployment.

    Must be specified as a list of absolute directory paths to existing directories.
    Contents are recursively included in the generated repository.
    Useful for adding custom policy definitions, templates from industry accelerators
    (e.g., Microsoft Cloud for Healthcare), or organization-specific extensions.

    Examples:
    - Windows: ["c:\\templates\\Microsoft_Cloud_for_Industry\\Common"]
    - Linux/Mac: ["/templates/Microsoft_Cloud_for_Industry/Common"]
  EOT
  type        = list(string)
  default     = []
}
