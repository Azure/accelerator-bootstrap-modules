variable "azure_location" {
  type = string
}

# Managed identities are now created externally and passed in
variable "managed_identity_ids" {
  type        = map(string)
  description = "Map of managed identity resource IDs (key = logical name like 'plan', 'apply')"
}

variable "managed_identity_client_ids" {
  type        = map(string)
  description = "Map of managed identity client IDs for outputs"
}

variable "managed_identity_principal_ids" {
  type        = map(string)
  description = "Map of managed identity principal IDs for role assignments"
}

variable "resource_group_identity_name" {
  type = string
}

variable "resource_group_agents_name" {
  type    = string
  default = ""
}

variable "resource_group_network_name" {
  type    = string
  default = ""
}

variable "resource_group_state_name" {
  type = string
}

variable "create_storage_account" {
  type    = bool
  default = true
}

variable "storage_account_name" {
  type = string
}

variable "storage_container_name" {
  type = string
}

variable "storage_account_replication_type" {
  type    = string
  default = "ZRS"
}

variable "agent_container_instances" {
  type = map(object({
    container_instance_name = string
    agent_name              = string
    cpu                     = optional(number, 4)
    memory                  = optional(number, 16)
    cpu_max                 = optional(number, 4)
    memory_max              = optional(number, 16)
    zones                   = optional(set(string), ["1"])
  }))
  default = {}
}

variable "agent_organization_url" {
  type    = string
  default = ""
}

variable "agent_token" {
  type      = string
  sensitive = true
  default   = ""
}

variable "agent_name_environment_variable" {
  type    = string
  default = ""
}

variable "agent_pool_name" {
  type    = string
  default = ""
}

variable "agent_pool_environment_variable" {
  type    = string
  default = ""
}

variable "use_agent_pool_environment_variable" {
  type    = bool
  default = true
}

variable "agent_organization_environment_variable" {
  type    = string
  default = ""
}

variable "agent_token_environment_variable" {
  type    = string
  default = ""
}

variable "target_subscriptions" {
  type = list(string)
}

variable "root_parent_management_group_id" {
  description = "The root management group name"
  type        = string
}

variable "resource_providers" {
  type        = set(string)
  description = "The resource providers to register"
  nullable    = false
  default = [
    "Microsoft.Authorization",
    "Microsoft.Automation",
    "Microsoft.Compute",
    "Microsoft.ContainerInstance",
    "Microsoft.ContainerRegistry",
    "Microsoft.ContainerService",
    "Microsoft.CostManagement",
    "Microsoft.CustomProviders",
    "Microsoft.DataProtection",
    "microsoft.insights",
    "Microsoft.Maintenance",
    "Microsoft.ManagedIdentity",
    "Microsoft.ManagedServices",
    "Microsoft.Management",
    "Microsoft.Network",
    "Microsoft.OperationalInsights",
    "Microsoft.OperationsManagement",
    "Microsoft.PolicyInsights",
    "Microsoft.RecoveryServices",
    "Microsoft.Resources",
    "Microsoft.Security",
    "Microsoft.SecurityInsights",
    "Microsoft.Storage",
    "Microsoft.StreamAnalytics"
  ]
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the virtual network"
  default     = ""
}

variable "virtual_network_address_space" {
  type        = string
  description = "The address space for the virtual network"
  default     = "10.0.0.0/24"
}

variable "public_ip_name" {
  type        = string
  description = "The name of the public ip"
  default     = ""
}

variable "nat_gateway_name" {
  type        = string
  description = "The name of the nat gateway"
  default     = ""
}

variable "virtual_network_subnet_name_container_instances" {
  type        = string
  description = "Name of the virtual network subnet"
  default     = ""
}

variable "virtual_network_subnet_name_private_endpoints" {
  type        = string
  description = "Name of the virtual network subnet"
  default     = ""
}

variable "virtual_network_subnet_address_prefix_container_instances" {
  type        = string
  description = "Address prefix for the virtual network subnet"
  default     = "10.0.0.0/26"
}

variable "virtual_network_subnet_address_prefix_private_endpoints" {
  type        = string
  description = "Address prefix for the virtual network subnet"
  default     = "10.0.0.64/26"
}

variable "virtual_network_subnet_name_container_apps" {
  type        = string
  description = "Name of the virtual network subnet for Container Apps"
  default     = ""
}

variable "virtual_network_subnet_address_prefix_container_apps" {
  type        = string
  description = "Address prefix for the Container Apps subnet"
  default     = "10.0.0.128/26"
}

variable "storage_account_private_endpoint_name" {
  type    = string
  default = ""
}

variable "use_private_networking" {
  description = "Controls whether to use private networking for the runner to storage account and runner to container registry communication"
  type        = bool
  default     = true
}

variable "allow_storage_access_from_my_ip" {
  type    = bool
  default = false
}

variable "container_registry_name" {
  type        = string
  description = "The name of the container registry"
  default     = ""
}

variable "container_registry_private_endpoint_name" {
  type    = string
  default = ""
}

variable "container_registry_dockerfile_repository_folder_url" {
  type        = string
  description = "The branch and folder of the repository containing the Dockerfile"
  default     = ""
}

variable "container_registry_dockerfile_name" {
  type        = string
  description = "The dockerfile to build"
  default     = "dockerfile"
}

variable "container_registry_image_name" {
  type        = string
  description = "The name of the image to build"
  default     = ""
}

variable "container_registry_image_tag" {
  type        = string
  description = "The pattern for the image tag"
  default     = "{{.Run.ID}}"
}

variable "use_self_hosted_agents" {
  type    = bool
  default = true
}

variable "use_container_app_jobs" {
  type        = bool
  default     = false
  description = "Whether to use Container App Jobs for self-hosted agents (Azure DevOps only). Mutually exclusive with Container Instances."
}

variable "agent_container_cpu" {
  type        = number
  default     = 2
  description = "CPU allocation for agent containers"
}

variable "agent_container_memory" {
  type        = number
  default     = 4
  description = "Memory allocation for agent containers in Gibibytes"
}

# Container App Jobs naming variables
variable "container_app_environment_name" {
  type        = string
  default     = ""
  description = "Name for the Container App Environment"
}

variable "container_app_job_name" {
  type        = string
  default     = ""
  description = "Name for the Container App Job"
}

variable "container_app_job_placeholder_name" {
  type        = string
  default     = ""
  description = "Name for the Container App Job placeholder"
}

variable "container_app_infrastructure_resource_group_name" {
  type        = string
  default     = ""
  description = "Name for the Container Apps infrastructure resource group"
}

variable "service_name" {
  type        = string
  description = "Service name for resource naming"
}

variable "environment_name" {
  type        = string
  description = "Environment name for resource naming"
}

variable "agent_container_instance_managed_identity_name" {
  type    = string
  default = ""
}

variable "custom_role_definitions" {
  description = "Custom role definitions to create"
  type = map(object({
    name        = string
    description = string
    permissions = object({
      actions     = list(string)
      not_actions = list(string)
    })
  }))
}

variable "role_assignments" {
  type = map(object({
    custom_role_definition_key         = string
    user_assigned_managed_identity_key = string
    scope                              = string
  }))
}

variable "additional_role_assignment_principal_ids" {
  type    = map(string)
  default = {}
}

variable "storage_account_blob_soft_delete_retention_days" {
  type    = number
  default = 7
}

variable "storage_account_blob_soft_delete_enabled" {
  type    = bool
  default = true
}

variable "storage_account_container_soft_delete_retention_days" {
  type    = number
  default = 7
}

variable "storage_account_container_soft_delete_enabled" {
  type    = bool
  default = true
}

variable "storage_account_blob_versioning_enabled" {
  type    = bool
  default = true
}
