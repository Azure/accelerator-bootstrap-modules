variable "azure_location" {
  description = <<-EOT
    **(Required)** Azure region where all bootstrap resources will be deployed.

    Must be a valid Azure region name (e.g., 'eastus', 'westeurope', 'uksouth').
    This location is used for resource groups, storage accounts, managed identities, and all other infrastructure components.
  EOT
  type        = string
}

variable "user_assigned_managed_identities" {
  description = <<-EOT
    **(Required)** Map of user-assigned managed identity names to create for Azure Landing Zones automation.

    Typically includes 'plan' and 'apply' identities used for Terraform/Bicep plan and apply operations
    with appropriate RBAC permissions.
  EOT
  type        = map(string)
}

variable "federated_credentials" {
  description = <<-EOT
    **(Optional, default: `{}`)** Configuration for OIDC federated identity credentials.

    Links user-assigned managed identities with external identity providers (GitHub Actions, Azure DevOps, etc.).
    Enables keyless authentication by establishing trust relationships between Azure and external CI/CD systems.

    Map structure:
    - **Key**: Unique identifier for the credential
    - **Value**: Object containing:
      - `user_assigned_managed_identity_key` (string) - Key of the managed identity to federate
      - `federated_credential_subject` (string) - Subject claim from external IdP
      - `federated_credential_issuer` (string) - Issuer URL of external IdP
      - `federated_credential_name` (string) - Display name for the credential
  EOT
  type = map(object({
    user_assigned_managed_identity_key = string
    federated_credential_subject       = string
    federated_credential_issuer        = string
    federated_credential_name          = string
  }))
  default = {}
}

variable "resource_group_identity_name" {
  description = <<-EOT
    **(Required)** Name of the Azure resource group for user-assigned managed identities.

    This resource group contains user-assigned managed identities and their federated credentials
    used for CI/CD authentication and authorization.
  EOT
  type        = string
}

variable "resource_group_agents_name" {
  description = <<-EOT
    **(Optional, default: `""`)** Name of the Azure resource group for self-hosted CI/CD agents.

    This resource group contains self-hosted CI/CD agents (container instances).
    Leave empty if not using self-hosted agents.
  EOT
  type        = string
  default     = ""
}

variable "resource_group_network_name" {
  description = <<-EOT
    **(Optional, default: `""`)** Name of the Azure resource group for networking resources.

    This resource group contains networking resources (virtual networks, subnets, NAT gateways, private endpoints).
    Leave empty if not using private networking.
  EOT
  type        = string
  default     = ""
}

variable "resource_group_state_name" {
  description = <<-EOT
    **(Required)** Name of the Azure resource group for Terraform state storage.

    This resource group contains the storage account for Terraform state files.
    Used to centrally manage state storage infrastructure.
  EOT
  type        = string
}

variable "create_storage_account" {
  description = <<-EOT
    **(Optional, default: `true`)** Controls whether to create an Azure Storage Account for Terraform state management.

    Set to false when using alternative state backends or when storage account already exists.
  EOT
  type        = bool
  default     = true
}

variable "storage_account_name" {
  description = <<-EOT
    **(Required)** Name of the Azure Storage Account for storing Terraform state files.

    Must be globally unique, 3-24 characters, lowercase letters and numbers only.
  EOT
  type        = string
}

variable "storage_container_name" {
  description = <<-EOT
    **(Required)** Name of the blob container for Terraform state files.

    Container within the storage account that will store Terraform state files.
    Typically named after the environment (e.g., 'mgmt-tfstate', 'prod-tfstate').
  EOT
  type        = string
}

variable "storage_account_replication_type" {
  description = <<-EOT
    **(Optional, default: `"ZRS"`)** Replication strategy for the storage account.

    Valid values: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS.
    ZRS recommended for production to ensure high availability across availability zones.
  EOT
  type        = string
  default     = "ZRS"
}

variable "agent_container_instances" {
  description = <<-EOT
    **(Optional, default: `{}`)** Configuration for self-hosted CI/CD agent container instances.

    Each entry defines a container with its resource allocation (CPU, memory), availability zones,
    and agent registration details. Used for Azure DevOps agents or GitHub runners running in
    Azure Container Instances.

    Map structure:
    - **Key**: Unique identifier for the container instance
    - **Value**: Object containing:
      - `container_instance_name` (string) - Name of the container instance
      - `agent_name` (string) - Name of the agent when registered
      - `cpu` (optional number, default: 4) - CPU cores allocated
      - `memory` (optional number, default: 16) - Memory in GB
      - `cpu_max` (optional number, default: 4) - Maximum CPU cores
      - `memory_max` (optional number, default: 16) - Maximum memory in GB
      - `zones` (optional set(string), default: ["1"]) - Availability zones
  EOT
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
  description = <<-EOT
    **(Optional, default: `""`)** The URL of the Azure DevOps organization or GitHub organization.

    The URL where agents will register.
    - For Azure DevOps: https://dev.azure.com/orgname
    - For GitHub: https://github.com/orgname
  EOT
  type        = string
  default     = ""
}

variable "agent_token" {
  description = <<-EOT
    **(Optional, default: `""`)** Personal Access Token (PAT) for registering self-hosted agents.

    Token for registering self-hosted agents with the CI/CD platform.
    - For Azure DevOps: requires 'Agent Pools - Read & Manage' scope
    - For GitHub: requires 'repo' scope

    Store securely and rotate regularly.
  EOT
  type        = string
  sensitive   = true
  default     = ""
}

variable "agent_name_environment_variable" {
  description = <<-EOT
    **(Optional, default: `""`)** Environment variable name used by the agent container to identify the agent name.

    Typically:
    - 'AZP_AGENT_NAME' for Azure DevOps
    - 'GH_RUNNER_NAME' for GitHub
  EOT
  type        = string
  default     = ""
}

variable "agent_pool_name" {
  description = <<-EOT
    **(Optional, default: `""`)** Name of the agent pool or runner group where self-hosted agents will register.

    - For Azure DevOps: this is the agent pool name
    - For GitHub Enterprise: this is the runner group name
  EOT
  type        = string
  default     = ""
}

variable "agent_pool_environment_variable" {
  description = <<-EOT
    **(Optional, default: `""`)** Environment variable name used by the agent container to specify the pool/group name.

    Typically:
    - 'AZP_POOL' for Azure DevOps
    - 'GH_RUNNER_GROUP' for GitHub
  EOT
  type        = string
  default     = ""
}

variable "use_agent_pool_environment_variable" {
  description = <<-EOT
    **(Optional, default: `true`)** Controls whether to pass the agent pool/runner group name as an environment variable to the container.

    Set to false if the container image handles pool assignment differently.
  EOT
  type        = bool
  default     = true
}

variable "agent_organization_environment_variable" {
  description = <<-EOT
    **(Optional, default: `""`)** Environment variable name used by the agent container to specify the organization URL.

    Typically:
    - 'AZP_URL' for Azure DevOps
    - 'GH_RUNNER_URL' for GitHub
  EOT
  type        = string
  default     = ""
}

variable "agent_token_environment_variable" {
  description = <<-EOT
    **(Optional, default: `""`)** Environment variable name used by the agent container to receive the authentication token.

    Typically:
    - 'AZP_TOKEN' for Azure DevOps
    - 'GH_RUNNER_TOKEN' for GitHub
  EOT
  type        = string
  default     = ""
}

variable "target_subscriptions" {
  description = <<-EOT
    **(Required)** List of Azure subscription IDs where Azure Landing Zones platform resources will be deployed.

    Typically includes management, connectivity, identity, and security subscriptions.
    Managed identities are granted appropriate permissions on these subscriptions.
  EOT
  type        = list(string)
}

variable "root_parent_management_group_id" {
  description = <<-EOT
    **(Required)** The ID of the root parent management group where Azure Landing Zones hierarchy starts.

    If not specified, defaults to the Tenant Root Group.
    Managed identities are granted permissions at this scope to manage the entire management group hierarchy.
  EOT
  type        = string
}

variable "move_subscriptions_to_target_management_group" {
  description = <<-EOT
    **(Optional, default: `true`)** Controls whether to move target subscriptions under the intermediate root management group.

    When enabled, subscriptions listed in `target_subscriptions` are moved under the created intermediate root management group.
    Ensures all landing zone subscriptions are organized under the same management group hierarchy.
  EOT
  type        = bool
  default     = true
}

variable "intermediate_root_management_group_creation_enabled" {
  description = <<-EOT
    **(Optional, default: `true`)** Controls whether to create an intermediate root management group under the root parent.

    When enabled, creates a dedicated management group to serve as the root for all Azure Landing Zones management groups and subscriptions.
    Helps isolate landing zone resources from other management groups in the tenant.
  EOT
  type        = bool
  default     = true
}

variable "intermediate_root_management_group_id" {
  description = <<-EOT
    **(Required)** The ID of the intermediate root management group to create under the root parent.

    This management group serves as the root for all Azure Landing Zones management groups and subscriptions.
    Must be unique within the tenant.
  EOT
  type        = string
}

variable "intermediate_root_management_group_display_name" {
  description = <<-EOT
    **(Required)** The display name for the intermediate root management group.

    This is a human-readable name shown in the Azure portal for the management group.
  EOT
  type        = string
}

variable "resource_providers" {
  description = <<-EOT
    **(Optional, default: comprehensive list)** The resource providers to register in the Azure subscription.

    Default includes all providers commonly needed for Azure Landing Zones:
    Authorization, Automation, Compute, ContainerInstance, ContainerRegistry, ContainerService,
    CostManagement, CustomProviders, DataProtection, Insights, Maintenance, ManagedIdentity,
    ManagedServices, Management, Network, OperationalInsights, OperationsManagement,
    PolicyInsights, RecoveryServices, Resources, Security, SecurityInsights, Storage, StreamAnalytics.
  EOT
  type        = set(string)
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
  description = <<-EOT
    **(Optional, default: `""`)** Name of the Azure Virtual Network for hosting self-hosted agents and private endpoints.

    Required when using private networking for secure communication between agents, storage, and container registry.
  EOT
  type        = string
  default     = ""
}

variable "virtual_network_address_space" {
  description = <<-EOT
    **(Optional, default: `"10.0.0.0/24"`)** CIDR address space for the virtual network.

    Must be large enough to accommodate all required subnets.
    Example: '10.0.0.0/24' provides 256 IP addresses.
  EOT
  type        = string
  default     = "10.0.0.0/24"
}

variable "public_ip_name" {
  description = <<-EOT
    **(Optional, default: `""`)** Name of the public IP address resource used by the NAT Gateway.

    Used for outbound internet connectivity from agents.
    Required when using private networking with NAT Gateway.
  EOT
  type        = string
  default     = ""
}

variable "nat_gateway_name" {
  description = <<-EOT
    **(Optional, default: `""`)** Name of the NAT Gateway that provides secure outbound internet access.

    Provides outbound internet access for container instances in the virtual network.
    Ensures consistent outbound IP address for agent traffic.
  EOT
  type        = string
  default     = ""
}

variable "virtual_network_subnet_name_container_instances" {
  description = <<-EOT
    **(Optional, default: `""`)** Name of the subnet delegated for Azure Container Instances.

    This subnet hosts self-hosted CI/CD agents and must be delegated to
    Microsoft.ContainerInstance/containerGroups.
  EOT
  type        = string
  default     = ""
}

variable "virtual_network_subnet_name_private_endpoints" {
  description = <<-EOT
    **(Optional, default: `""`)** Name of the subnet for private endpoints.

    This subnet hosts private endpoints for storage account and container registry,
    enabling private connectivity without public internet exposure.
  EOT
  type        = string
  default     = ""
}

variable "virtual_network_subnet_address_prefix_container_instances" {
  description = <<-EOT
    **(Optional, default: `"10.0.0.0/26"`)** CIDR address prefix for the container instances subnet.

    Must be within the virtual network address space and large enough for expected number of container instances.
    Example: '10.0.0.0/26' provides 64 addresses.
  EOT
  type        = string
  default     = "10.0.0.0/26"
}

variable "virtual_network_subnet_address_prefix_private_endpoints" {
  description = <<-EOT
    **(Optional, default: `"10.0.0.64/26"`)** CIDR address prefix for the private endpoints subnet.

    Must be within the virtual network address space.
    Typically smaller than container subnet as fewer endpoints are needed.
    Example: '10.0.0.64/26' provides 64 addresses.
  EOT
  type        = string
  default     = "10.0.0.64/26"
}

variable "storage_account_private_endpoint_name" {
  description = <<-EOT
    **(Optional, default: `""`)** Name of the private endpoint for the storage account.

    Enables private connectivity to the storage account from the virtual network,
    blocking public internet access.
  EOT
  type        = string
  default     = ""
}

variable "use_private_networking" {
  description = <<-EOT
    **(Optional, default: `true`)** Enable private networking for secure communication.

    When enabled, resources are accessed via private endpoints within the virtual network,
    enhancing security by eliminating public internet exposure between CI/CD agents,
    storage account, and container registry.
  EOT
  type        = bool
  default     = true
}

variable "allow_storage_access_from_my_ip" {
  description = <<-EOT
    **(Optional, default: `false`)** Temporarily allow storage account access from the current public IP address.

    Useful for initial setup and troubleshooting.
    Recommended to keep disabled (false) in production for security.
    When enabled, adds current IP to storage account firewall rules.
  EOT
  type        = bool
  default     = false
}

variable "container_registry_name" {
  description = <<-EOT
    **(Optional, default: `""`)** Name of the Azure Container Registry for storing CI/CD agent container images.

    Must be globally unique, 5-50 characters, alphanumeric only.
  EOT
  type        = string
  default     = ""
}

variable "container_registry_private_endpoint_name" {
  description = <<-EOT
    **(Optional, default: `""`)** Name of the private endpoint for the container registry.

    Enables private connectivity to the registry from the virtual network,
    securing container image pulls.
  EOT
  type        = string
  default     = ""
}

variable "container_registry_dockerfile_repository_folder_url" {
  description = <<-EOT
    **(Optional, default: `""`)** URL to the git repository folder containing the Dockerfile.

    Format: https://github.com/org/repo/tree/branch/folder
    Used by Azure Container Registry tasks to build custom CI/CD agent images.
  EOT
  type        = string
  default     = ""
}

variable "container_registry_dockerfile_name" {
  description = <<-EOT
    **(Optional, default: `"Dockerfile"`)** Name of the Dockerfile to build in the repository folder.

    Typically 'Dockerfile' or a specific variant like 'dockerfile', 'Dockerfile.ubuntu', etc.
  EOT
  type        = string
  default     = "Dockerfile"
}

variable "container_registry_image_name" {
  description = <<-EOT
    **(Optional, default: `""`)** Name for the container image built from the Dockerfile.

    Used as the image repository name in the container registry.
    Examples: 'azure-devops-agent', 'github-runner'
  EOT
  type        = string
  default     = ""
}

variable "container_registry_zone_redundancy_enabled" {
  description = <<-EOT
    **(Optional, default: `true`)** Enable zone redundancy for the Azure Container Registry.

    When enabled, the container registry is replicated across availability zones for higher availability.
    Some regions do not support zone redundancy, in which case this should be set to false.
    Zone redundancy requires Premium SKU, which is only used when private networking is enabled.
  EOT
  type        = bool
  default     = true
}

variable "container_registry_image_tag" {
  description = <<-EOT
    **(Optional, default: `"{{.Run.ID}}"`)** Tag pattern for the container image.

    Supports ACR task variables like {{.Run.ID}} for dynamic tagging.
    Examples: 'latest', 'v1.0.0', '{{.Run.ID}}' for build-specific tags.
  EOT
  type        = string
  default     = "{{.Run.ID}}"
}

variable "use_self_hosted_agents" {
  description = <<-EOT
    **(Optional, default: `true`)** Controls whether to deploy self-hosted CI/CD agents in Azure Container Instances.

    When false, assumes use of cloud-hosted agents (GitHub-hosted runners or Microsoft-hosted agents).
  EOT
  type        = bool
  default     = true
}

variable "agent_container_instance_managed_identity_name" {
  description = <<-EOT
    **(Optional, default: `""`)** Name of the user-assigned managed identity attached to agent container instances.

    This identity is used for authenticating to container registry to pull agent images.
    Separate from the plan/apply identities used for infrastructure deployments.
  EOT
  type        = string
  default     = ""
}

variable "custom_role_definitions" {
  description = <<-EOT
    **(Required)** Map of custom Azure RBAC role definitions to create for Azure Landing Zones automation.

    Each role defines permissions (actions/notActions) required for managing management groups,
    subscriptions, and Azure Landing Zones resources.
    Keys reference these roles in role_assignments variable.

    Map structure:
    - **Key**: Role identifier (e.g., 'alz_management_group_contributor')
    - **Value**: Object containing:
      - `name` (string) - Display name for the role
      - `description` (string) - Role purpose description
      - `permissions` (object):
        - `actions` (list(string)) - Allowed Azure actions
        - `not_actions` (list(string)) - Denied Azure actions
  EOT
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
  description = <<-EOT
    **(Required)** Map of role assignments linking custom role definitions to managed identities at specific scopes.

    Defines what permissions each managed identity has and where those permissions apply.
    Valid scopes: 'management_group' or 'subscription'

    Map structure:
    - **Key**: Assignment identifier (e.g., 'plan_management_group')
    - **Value**: Object containing:
      - `built_in_role_definition_name` (string) - Name of built-in role (optional)
      - `custom_role_definition_key` (string) - Key from custom_role_definitions
      - `user_assigned_managed_identity_key` (string) - Key from user_assigned_managed_identities
      - `scope` (string) - Assignment scope ('management_group' or 'subscription')
  EOT
  type = map(object({
    built_in_role_definition_name      = optional(string)
    custom_role_definition_key         = optional(string)
    user_assigned_managed_identity_key = string
    scope                              = string
  }))
}

variable "additional_role_assignment_principal_ids" {
  description = <<-EOT
    **(Optional, default: `{}`)** Additional Azure AD principal IDs to grant the same role assignments.

    Map of principal IDs (users, groups, service principals) to grant the same role assignments
    as the managed identities. Useful for granting permissions to human operators or existing
    service principals for troubleshooting or manual operations.
  EOT
  type        = map(string)
  default     = {}
}

variable "tenant_role_assignment_enabled" {
  description = <<-EOT
    **(Optional, default: `false`)** Enable tenant-level role assignment for managed identities.

    When enabled, assigns the specified role at the tenant root scope, required for some
    Bicep operations that need tenant-wide visibility.
    Use cautiously as this grants broad permissions.
  EOT
  type        = bool
  default     = false
}

variable "tenant_role_assignment_role_definition_name" {
  description = <<-EOT
    **(Optional, default: `"Landing Zone Management Owner"`)** Name of the role to assign at tenant root scope.

    For Bicep deployments, typically 'Landing Zone Management Owner' or a custom tenant-scoped role.
    Must have appropriate tenant-level permissions.
  EOT
  type        = string
  default     = "Landing Zone Management Owner"
}

variable "storage_account_blob_soft_delete_retention_days" {
  description = <<-EOT
    **(Optional, default: `7`)** Number of days to retain soft-deleted blobs in the storage account.

    Soft delete protects Terraform state files from accidental deletion by retaining deleted blobs
    for the specified period, allowing recovery if needed.
    Valid range: 1-365 days.
  EOT
  type        = number
  default     = 7
}

variable "storage_account_blob_soft_delete_enabled" {
  description = <<-EOT
    **(Optional, default: `true`)** Enable soft delete protection for blobs in the storage account.

    When enabled, deleted blobs (including Terraform state files) are retained for the configured
    retention period and can be restored.
    Highly recommended for production environments.
  EOT
  type        = bool
  default     = true
}

variable "storage_account_container_soft_delete_retention_days" {
  description = <<-EOT
    **(Optional, default: `7`)** Number of days to retain soft-deleted containers in the storage account.

    Protects against accidental container deletion by retaining deleted containers
    for the specified period.
    Valid range: 1-365 days.
  EOT
  type        = number
  default     = 7
}

variable "storage_account_container_soft_delete_enabled" {
  description = <<-EOT
    **(Optional, default: `true`)** Enable soft delete protection for containers in the storage account.

    When enabled, deleted containers are retained for the configured retention period and can be restored.
    Provides an additional layer of protection for Terraform state storage.
  EOT
  type        = bool
  default     = true
}

variable "storage_account_blob_versioning_enabled" {
  description = <<-EOT
    **(Optional, default: `true`)** Enable blob versioning for the storage account.

    When enabled, Azure automatically maintains previous versions of blobs, providing protection
    against accidental overwrites and enabling point-in-time recovery of Terraform state files.
    Essential for production state management.
  EOT
  type        = bool
  default     = true
}
