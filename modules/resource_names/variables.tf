variable "azure_location" {
  description = <<-EOT
    **(Required)** Azure region where bootstrap resources will be deployed.

    Used in resource naming to indicate the geographic location.
    Examples: 'eastus', 'westeurope', 'uksouth'

    This value is transformed to location codes (e.g., 'eus', 'weu', 'uks') for abbreviated resource names.
  EOT
  type        = string
}

variable "environment_name" {
  description = <<-EOT
    **(Required)** Environment name used in resource naming to indicate the deployment purpose.

    Common values: 'mgmt' (management), 'prod' (production), 'dev' (development), 'test'

    Must contain only lowercase letters and numbers for Azure naming compliance.
  EOT
  type        = string
}

variable "service_name" {
  description = <<-EOT
    **(Required)** Service name used in resource naming to identify the workload or service.

    Typically 'alz' for Azure Landing Zones.
    Must contain only lowercase letters and numbers.
    Used as a primary identifier in all generated resource names.
  EOT
  type        = string
}

variable "postfix_number" {
  description = <<-EOT
    **(Required)** Numeric postfix appended to resource names for uniqueness and versioning.

    Typically starts at 1.
    Used to distinguish between multiple deployments of the same service in the same environment and location.
    Incremented values (postfix + 1) are also generated for resources requiring multiple instances.
  EOT
  type        = number
}

variable "resource_names" {
  description = <<-EOT
    **(Required)** Map of resource name templates with placeholders for variable substitution.

    Templates use tokens like:
    - `{{service_name}}` - Replaced with var.service_name
    - `{{environment_name}}` - Replaced with var.environment_name
    - `{{azure_location}}` - Replaced with Azure region
    - `{{postfix_number}}` - Replaced with var.postfix_number

    This module processes these templates to generate final resource names compliant with Azure naming requirements.
  EOT
  type        = map(string)
}
