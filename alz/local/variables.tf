variable "iac_type" {
  description = <<-EOT
    **(Required)** The type of infrastructure as code to use for the deployment.

    Valid values: 'terraform', 'bicep', or 'bicep-classic'
  EOT
  type        = string
}

variable "module_folder_path" {
  description = <<-EOT
    **(Required)** The filesystem path to the folder containing ALZ starter modules.

    This folder contains the infrastructure as code templates that will be deployed.
  EOT
  type        = string
}

variable "root_parent_management_group_id" {
  description = <<-EOT
    **(Optional, default: `""`)**  The root parent management group ID.

    If not supplied, defaults to the Tenant Root Group ID.
  EOT
  type        = string
  default     = ""
}

variable "subscription_ids" {
  description = <<-EOT
    **(Optional, default: `{}`)**  Map of Azure subscription IDs where Platform Landing Zone resources will be deployed.

    Keys must be one of: 'management', 'connectivity', 'identity', 'security'
    Values must be valid Azure subscription GUIDs.

    Example:
    ```
    {
      management   = "00000000-0000-0000-0000-000000000000"
      connectivity = "11111111-1111-1111-1111-111111111111"
    }
    ```
  EOT
  type        = map(string)
  default     = {}
  nullable    = false
  validation {
    condition     = alltrue([for id in values(var.subscription_ids) : can(regex("^[0-9a-fA-F-]{36}$", id))])
    error_message = "All subscription IDs must be valid GUIDs"
  }
  validation {
    condition     = alltrue([for id in keys(var.subscription_ids) : contains(["management", "connectivity", "identity", "security"], id)])
    error_message = "The keys of the subscription_ids map must be one of 'management', 'connectivity', 'identity' or 'security'"
  }
  validation {
    condition     = contains(keys(var.subscription_ids), "management") && contains(keys(var.subscription_ids), "connectivity") && contains(keys(var.subscription_ids), "identity")
    error_message = "You must provide subscription IDs for: 'management', 'connectivity', and 'identity'"
  }
}

variable "configuration_file_path" {
  description = <<-EOT
    **(Optional, default: `""`)** The filesystem path to the configuration file.

    This file contains additional deployment parameters for the ALZ deployment.
  EOT
  type        = string
  default     = ""
}

variable "starter_module_name" {
  description = <<-EOT
    **(Optional, default: `""`)** The name of the ALZ starter module to deploy.

    Identifies which starter module template to use for the deployment.
  EOT
  type        = string
  default     = ""
}

variable "bootstrap_location" {
  description = <<-EOT
    **(Optional, default: `""`)** The Azure region where bootstrap resources will be deployed.

    Specifies the location for storage accounts, managed identities, and other bootstrap resources.
    Examples: 'uksouth', 'eastus', 'westeurope'
  EOT
  type        = string
  default     = ""
}

variable "on_demand_folder_repository" {
  description = <<-EOT
    **(Optional, default: `""`)** The Git repository URL for on-demand folder sources.

    Specifies the repository containing additional deployment folders.
  EOT
  type        = string
  default     = ""
}

variable "on_demand_folder_artifact_name" {
  description = <<-EOT
    **(Optional, default: `""`)** The branch or artifact name for on-demand folders.

    Specifies which branch or version to use from the on-demand folder repository.
  EOT
  type        = string
  default     = ""
}

variable "target_directory" {
  description = <<-EOT
    **(Optional, default: `""`)** The filesystem path where landing zone files will be created.

    Examples:
    - Windows: 'c:\landingzones\my_landing_zone'
    - Linux/Mac: '/home/user/landingzones/my_landing_zone'
  EOT
  type        = string
  default     = ""
}

variable "create_bootstrap_resources_in_azure" {
  description = <<-EOT
    **(Optional, default: `true`)** Whether to create bootstrap resources in Azure.

    When true, provisions resource groups, storage accounts, managed identities, and other bootstrap infrastructure.
  EOT
  type        = bool
  default     = true
}

variable "bootstrap_subscription_id" {
  description = <<-EOT
    **(Optional, default: `""`)** The Azure subscription ID where bootstrap resources will be deployed.

    If empty, uses the currently logged-in subscription from Azure CLI.
    Must be a valid GUID format.
  EOT
  type        = string
  default     = ""
  validation {
    condition     = var.bootstrap_subscription_id == "" ? true : can(regex("^[0-9a-fA-F-]{36}$", var.bootstrap_subscription_id))
    error_message = "The bootstrap subscription ID must be a valid GUID"
  }
}

variable "service_name" {
  description = <<-EOT
    **(Optional, default: `"alz"`)**  Used to build up the default resource names.

    Example: rg-**<service_name>**-mgmt-uksouth-001

    Must contain only lowercase letters and numbers.
  EOT
  type        = string
  default     = "alz"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.service_name))
    error_message = "The service name must only contain lowercase letters and numbers"
  }
}

variable "environment_name" {
  description = <<-EOT
    **(Optional, default: `"mgmt"`)** Used to build up the default resource names.

    Example: rg-alz-**<environment_name>**-uksouth-001

    Must contain only lowercase letters and numbers.
  EOT
  type        = string
  default     = "mgmt"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.environment_name))
    error_message = "The environment name must only contain lowercase letters and numbers"
  }
}

variable "postfix_number" {
  description = <<-EOT
    **(Optional, default: `1`)**  Used to build up the default resource names.

    Example: rg-alz-mgmt-uksouth-**<postfix_number>**
  EOT
  type        = number
  default     = 1
}

variable "additional_files" {
  description = <<-EOT
    **(Optional, default: `[]`)** Additional files to include in the deployment.

    Must be specified as a list of absolute file paths.
    Examples:
    - Windows: ["c:\\config\\config.yaml", "c:\\scripts\\deploy.ps1"]
    - Linux/Mac: ["/home/user/config/config.yaml", "/home/user/scripts/deploy.sh"]
  EOT
  type        = list(string)
  default     = []
}

variable "additional_folders_path" {
  description = <<-EOT
    **(Optional, default: `[]`)** Additional folders to include in the deployment.

    Must be specified as a list of absolute directory paths.
    Examples:
    - Windows: ["c:\\templates\\Microsoft_Cloud_for_Industry\\Common"]
    - Linux/Mac: ["/templates/Microsoft_Cloud_for_Industry/Common"]
  EOT
  type        = list(string)
  default     = []
}

variable "built_in_configuration_file_names" {
  description = <<-EOT
    **(Optional, default: `["config.yaml", "config-hub-and-spoke-vnet.yaml", "config-virtual-wan.yaml"]`)**
    List of built-in configuration file names available for ALZ deployments.

    These files provide pre-configured deployment options for different network topologies.
  EOT
  type        = list(string)
  default     = ["config.yaml", "config-hub-and-spoke-vnet.yaml", "config-virtual-wan.yaml"]
}

variable "module_folder_path_relative" {
  description = <<-EOT
    **(Optional, default: `false`)** Whether the module_folder_path is relative to the bootstrap module.

    When true, interprets module_folder_path as relative to the bootstrap module's location.
    When false, interprets module_folder_path as an absolute path.
  EOT
  type        = bool
  default     = false
}

variable "resource_names" {
  description = <<-EOT
    **(Optional, default: `{}`)** Custom resource name overrides for Azure bootstrap resources.

    Allows customization of naming patterns using template variables:
    - `{{service_name}}` - Replaced with var.service_name
    - `{{environment_name}}` - Replaced with var.environment_name
    - `{{azure_location}}` - Replaced with Azure region
    - `{{postfix_number}}` - Replaced with var.postfix_number
    - `{{random_string}}` - Replaced with generated random string
    - `{{service_name_short}}`, `{{environment_name_short}}`, `{{azure_location_short}}` - Shortened versions

    Object fields:
    - `resource_group_state` (optional) - Resource group for Terraform/Bicep state storage
    - `resource_group_identity` (optional) - Resource group for managed identities
    - `user_assigned_managed_identity_plan` (optional) - Managed identity for plan operations
    - `user_assigned_managed_identity_apply` (optional) - Managed identity for apply operations
    - `user_assigned_managed_identity_federated_credentials_prefix` (optional) - Prefix for federated credential names
    - `storage_account` (optional) - Storage account for state files
    - `storage_container` (optional) - Blob container for state files

    All fields are optional and use default templates if not specified.
  EOT
  type = object({
    resource_group_state                                        = optional(string, "rg-{{service_name}}-{{environment_name}}-state-{{azure_location}}-{{postfix_number}}")
    resource_group_identity                                     = optional(string, "rg-{{service_name}}-{{environment_name}}-identity-{{azure_location}}-{{postfix_number}}")
    user_assigned_managed_identity_plan                         = optional(string, "id-{{service_name}}-{{environment_name}}-{{azure_location}}-plan-{{postfix_number}}")
    user_assigned_managed_identity_apply                        = optional(string, "id-{{service_name}}-{{environment_name}}-{{azure_location}}-apply-{{postfix_number}}")
    user_assigned_managed_identity_federated_credentials_prefix = optional(string, "{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}")
    storage_account                                             = optional(string, "sto{{service_name_short}}{{environment_name_short}}{{azure_location_short}}{{postfix_number}}{{random_string}}")
    storage_container                                           = optional(string, "{{environment_name}}-tfstate")
  })
  default = {}
}

variable "federated_credentials" {
  description = <<-EOT
    **(Optional, default: `{}`)** Configuration for OIDC federated identity credentials.

    Enables keyless authentication from external CI/CD systems to Azure by establishing trust
    relationships between Azure managed identities and external identity providers.

    Map of federated credential configurations where:
    - **Key**: Unique identifier for the credential
    - **Value**: Object containing:
      - `user_assigned_managed_identity_key` (string) - Key of the managed identity to federate
      - `federated_credential_subject` (string) - Subject claim from external IdP
      - `federated_credential_issuer` (string) - Issuer URL of external IdP
      - `federated_credential_name` (string) - Display name for the credential

    Example for GitHub Actions:
    ```
    {
      github_plan = {
        user_assigned_managed_identity_key = "plan"
        federated_credential_subject       = "repo:my-org/my-repo:environment:plan"
        federated_credential_issuer        = "https://token.actions.githubusercontent.com"
        federated_credential_name          = "github-plan-credential"
      }
    }
    ```
  EOT
  type = map(object({
    user_assigned_managed_identity_key = string
    federated_credential_subject       = string
    federated_credential_issuer        = string
    federated_credential_name          = string
  }))
  default = {}
}

variable "default_target_directory" {
  description = <<-EOT
    **(Optional, default: `"../../../../local-output"`)** The default directory for landing zone file output.

    Used as a fallback when target_directory is not specified.
    Relative paths are evaluated from the module's location.
  EOT
  type        = string
  default     = "../../../../local-output"
}

variable "storage_account_replication_type" {
  description = <<-EOT
    **(Optional, default: `"ZRS"`)** The replication strategy for the Azure storage account storing state files.

    Valid values:
    - `LRS` - Locally Redundant Storage
    - `GRS` - Geo-Redundant Storage
    - `RAGRS` - Read-Access Geo-Redundant Storage
    - `ZRS` - Zone-Redundant Storage (recommended for high availability)
    - `GZRS` - Geo-Zone-Redundant Storage
    - `RAGZRS` - Read-Access Geo-Zone-Redundant Storage
  EOT
  type        = string
  default     = "ZRS"
}

variable "custom_role_definitions_terraform" {
  description = <<-EOT
    **(Optional)** Custom Azure RBAC role definitions for Terraform-based deployments.

    Map of role definition configurations where:
    - **Key**: Role identifier (e.g., 'alz_management_group_contributor')
    - **Value**: Object containing:
      - `name` (string) - Display name (supports template variables like {{service_name}})
      - `description` (string) - Role purpose description
      - `permissions` (object):
        - `actions` (list(string)) - Allowed Azure actions
        - `not_actions` (list(string)) - Denied Azure actions

    Default is empty, meaning no custom roles are created.

    See default value for complete role action definitions.
  EOT
  type = map(object({
    name        = string
    description = string
    permissions = object({
      actions     = list(string)
      not_actions = list(string)
    })
  }))
  default = {}
}

variable "custom_role_definitions_bicep" {
  description = <<-EOT
    **(Optional)** Custom Azure RBAC role definitions for Bicep-based deployments.

    Map of role definition configurations where:
    - **Key**: Role identifier (e.g., 'alz_management_group_contributor')
    - **Value**: Object containing:
      - `name` (string) - Display name (supports template variables like {{service_name}})
      - `description` (string) - Role purpose description
      - `permissions` (object):
        - `actions` (list(string)) - Allowed Azure actions
        - `not_actions` (list(string)) - Denied Azure actions

    Default includes 1 predefined roles:
    - `alz_reader` - Run Bicep What-If validations (requires --validation-level providerNoRbac flag)s

    See default value for complete role action definitions.
  EOT
  type = map(object({
    name        = string
    description = string
    permissions = object({
      actions     = list(string)
      not_actions = list(string)
    })
  }))
  default = {
    alz_reader = {
      name        = "Azure Landing Zones Management Group What If ({{service_name}}-{{environment_name}})"
      description = "This is a custom role created by the Azure Landing Zones Accelerator for running Bicep What If for the Management Group hierarchy and its associated governance resources such as policy, RBAC etc... You must use the `--validation-level providerNoRbac` (Az CLI 2.75.0 or later) or `-ValidationLevel providerNoRbac` (Az PowerShell 13.4.0 or later (Az.Resources 7.10.0 or later)) flag when running Bicep What If with this role."
      permissions = {
        actions = [
          "Microsoft.Resources/deployments/whatIf/action",
          "Microsoft.Resources/deployments/validate/action",
        ]
        not_actions = []
      }
    }
  }
}

variable "custom_role_definitions_bicep_classic" {
  description = <<-EOT
    **(Optional)** Custom Azure RBAC role definitions for Bicep-based deployments.

    Map of role definition configurations where:
    - **Key**: Role identifier (e.g., 'alz_management_group_contributor')
    - **Value**: Object containing:
      - `name` (string) - Display name (supports template variables like {{service_name}})
      - `description` (string) - Role purpose description
      - `permissions` (object):
        - `actions` (list(string)) - Allowed Azure actions
        - `not_actions` (list(string)) - Denied Azure actions

    Default includes 4 predefined roles:
    - `alz_management_group_contributor` - Manage management group hierarchy and governance
    - `alz_management_group_reader` - Run Bicep What-If validations (requires --validation-level providerNoRbac flag)
    - `alz_subscription_owner` - Full access to platform subscriptions
    - `alz_subscription_reader` - Run Bicep What-If for subscription deployments

    See default value for complete role action definitions.
  EOT
  type = map(object({
    name        = string
    description = string
    permissions = object({
      actions     = list(string)
      not_actions = list(string)
    })
  }))
  default = {
    alz_management_group_contributor = {
      name        = "Azure Landing Zones Management Group Contributor ({{service_name}}-{{environment_name}})"
      description = "This is a custom role created by the Azure Landing Zones Accelerator for Writing the Management Group Structure."
      permissions = {
        actions = [
          "Microsoft.Management/managementGroups/delete",
          "Microsoft.Management/managementGroups/read",
          "Microsoft.Management/managementGroups/subscriptions/delete",
          "Microsoft.Management/managementGroups/subscriptions/write",
          "Microsoft.Management/managementGroups/write",
          "Microsoft.Management/managementGroups/subscriptions/read",
          "Microsoft.Management/managementGroups/settings/read",
          "Microsoft.Management/managementGroups/settings/write",
          "Microsoft.Management/managementGroups/settings/delete",
          "Microsoft.Authorization/policyDefinitions/write",
          "Microsoft.Authorization/policySetDefinitions/write",
          "Microsoft.Authorization/policyAssignments/write",
          "Microsoft.Authorization/roleDefinitions/write",
          "Microsoft.Authorization/*/read",
          "Microsoft.Resources/deployments/whatIf/action",
          "Microsoft.Resources/deployments/write",
          "Microsoft.Resources/deployments/validate/action",
          "Microsoft.Resources/deployments/read",
          "Microsoft.Resources/deployments/operationStatuses/read",
          "Microsoft.Authorization/roleAssignments/write",
          "Microsoft.Authorization/roleAssignments/delete",
          "Microsoft.Insights/diagnosticSettings/write"
        ]
        not_actions = []
      }
    }
    alz_management_group_reader = {
      name        = "Azure Landing Zones Management Group What If ({{service_name}}-{{environment_name}})"
      description = "This is a custom role created by the Azure Landing Zones Accelerator for running Bicep What If for the Management Group Structure."
      permissions = {
        actions = [
          "Microsoft.Management/managementGroups/read",
          "Microsoft.Management/managementGroups/subscriptions/read",
          "Microsoft.Management/managementGroups/settings/read",
          "Microsoft.Authorization/*/read",
          "Microsoft.Authorization/policyDefinitions/write",
          "Microsoft.Authorization/policySetDefinitions/write",
          "Microsoft.Authorization/roleDefinitions/write",
          "Microsoft.Authorization/policyAssignments/write",
          "Microsoft.Insights/diagnosticSettings/write",
          "Microsoft.Insights/diagnosticSettings/read",
          "Microsoft.Resources/deployments/whatIf/action",
          "Microsoft.Resources/deployments/write"
        ]
        not_actions = []
      }
    }
    alz_subscription_owner = {
      name        = "Azure Landing Zones Subscription Owner ({{service_name}}-{{environment_name}})"
      description = "This is a custom role created by the Azure Landing Zones Accelerator for Writing in platform subscriptions."
      permissions = {
        actions = [
          "*",
          "Microsoft.Resources/deployments/whatIf/action",
          "Microsoft.Resources/deployments/write"
        ]
        not_actions = []
      }
    }
    alz_subscription_reader = {
      name        = "Azure Landing Zones Subscription What If ({{service_name}}-{{environment_name}})"
      description = "This is a custom role created by the Azure Landing Zones Accelerator for running Bicep What If for the platform subscriptions."
      permissions = {
        actions = [
          "*/read",
          "Microsoft.Resources/subscriptions/resourceGroups/write",
          "Microsoft.ManagedIdentity/userAssignedIdentities/write",
          "Microsoft.Automation/automationAccounts/write",
          "Microsoft.OperationalInsights/workspaces/write",
          "Microsoft.OperationalInsights/workspaces/linkedServices/write",
          "Microsoft.OperationsManagement/solutions/write",
          "Microsoft.Insights/dataCollectionRules/write",
          "Microsoft.Authorization/locks/write",
          "Microsoft.Network/*/write",
          "Microsoft.Resources/deployments/whatIf/action",
          "Microsoft.Resources/deployments/write",
          "Microsoft.SecurityInsights/onboardingStates/write"
        ]
        not_actions = []
      }
    }
  }
}

variable "role_assignments_terraform" {
  description = <<-EOT
    **(Optional)** RBAC role assignments for Terraform-based deployments.

    Map of role assignment configurations where:
    - **Key**: Assignment identifier (e.g., 'plan_management_group')
    - **Value**: Object containing:
      - `built_in_role_definition_name` (string) - Name of built-in role (e.g., 'Owner', 'Contributor')
      - `custom_role_definition_key` (string) - Key from custom_role_definitions_terraform
      - `user_assigned_managed_identity_key` (string) - Managed identity key ('plan' or 'apply')
      - `scope` (string) - Assignment scope ('management_group' or 'subscription')

    Default includes 2 assignments:
    - Plan and apply access

  EOT
  type = map(object({
    built_in_role_definition_name      = optional(string)
    custom_role_definition_key         = optional(string)
    user_assigned_managed_identity_key = string
    scope                              = string
  }))
  default = {
    plan = {
      built_in_role_definition_name      = "Reader"
      user_assigned_managed_identity_key = "plan"
      scope                              = "management_group"
    }
    apply = {
      built_in_role_definition_name      = "Owner"
      user_assigned_managed_identity_key = "apply"
      scope                              = "management_group"
    }
  }
}

variable "role_assignments_bicep" {
  description = <<-EOT
    **(Optional)** RBAC role assignments for Bicep-based deployments.

    Map of role assignment configurations where:
    - **Key**: Assignment identifier (e.g., 'plan_management_group')
    - **Value**: Object containing:
      - `built_in_role_definition_name` (string) - Name of built-in role (e.g., 'Owner', 'Contributor')
      - `custom_role_definition_key` (string) - Key from custom_role_definitions_bicep
      - `user_assigned_managed_identity_key` (string) - Managed identity key ('plan' or 'apply')
      - `scope` (string) - Assignment scope ('management_group' or 'subscription')

    Default includes 3 assignments:
    - Plan and apply access operations
  EOT
  type = map(object({
    built_in_role_definition_name      = optional(string)
    custom_role_definition_key         = optional(string)
    user_assigned_managed_identity_key = string
    scope                              = string
  }))
  default = {
    plan = {
      built_in_role_definition_name      = "Reader"
      user_assigned_managed_identity_key = "plan"
      scope                              = "management_group"
    }
    plan_custom = {
      custom_role_definition_key         = "alz_reader"
      user_assigned_managed_identity_key = "plan"
      scope                              = "management_group"
    }
    apply_management_group = {
      built_in_role_definition_name      = "Owner"
      user_assigned_managed_identity_key = "apply"
      scope                              = "management_group"
    }
  }
}

variable "role_assignments_bicep_classic" {
  description = <<-EOT
    **(Optional)** RBAC role assignments for Bicep Classic based deployments.

    Map of role assignment configurations where:
    - **Key**: Assignment identifier (e.g., 'plan_management_group')
    - **Value**: Object containing:
      - `built_in_role_definition_name` (string) - Name of built-in role (e.g., 'Owner', 'Contributor')
      - `custom_role_definition_key` (string) - Key from custom_role_definitions_bicep
      - `user_assigned_managed_identity_key` (string) - Managed identity key ('plan' or 'apply')
      - `scope` (string) - Assignment scope ('management_group' or 'subscription')

    Default includes 4 assignments:
    - Plan and apply access for management group operations
    - Plan and apply access for subscription operations
  EOT
  type = map(object({
    built_in_role_definition_name      = optional(string)
    custom_role_definition_key         = optional(string)
    user_assigned_managed_identity_key = string
    scope                              = string
  }))
  default = {
    plan_management_group = {
      custom_role_definition_key         = "alz_management_group_reader"
      user_assigned_managed_identity_key = "plan"
      scope                              = "management_group"
    }
    apply_management_group = {
      custom_role_definition_key         = "alz_management_group_contributor"
      user_assigned_managed_identity_key = "apply"
      scope                              = "management_group"
    }
    plan_subscription = {
      custom_role_definition_key         = "alz_subscription_reader"
      user_assigned_managed_identity_key = "plan"
      scope                              = "subscription"
    }
    apply_subscription = {
      custom_role_definition_key         = "alz_subscription_owner"
      user_assigned_managed_identity_key = "apply"
      scope                              = "subscription"
    }
  }
}

variable "bicep_config_file_path" {
  description = <<-EOT
    **(Optional, default: `".config/ALZ-Powershell.config.json"`)** Path to the Bicep configuration file.

    Contains deployment settings and parameters for the Azure Landing Zones Bicep accelerator.
    Can be an absolute or relative path. This file configures the PowerShell-based deployment workflow.
  EOT
  type        = string
  default     = ".config/ALZ-Powershell.config.json"
}

variable "bicep_parameters_file_path" {
  description = <<-EOT
    **(Optional, default: `"parameters.json"`)** Path to the Bicep parameters file.

    Contains input values for the Bicep template deployment.
    This JSON file specifies configuration values for Azure Landing Zones resources.
  EOT
  type        = string
  default     = "template-parameters.json"
}

variable "root_module_folder_relative_path" {
  description = <<-EOT
    **(Optional, default: `"."`)** The relative path from output directory to the root module folder.

    Used to establish correct path references in generated deployment scripts.
    The root module folder contains the main Terraform or Bicep configuration.
  EOT
  type        = string
  default     = "."
}

variable "storage_account_blob_soft_delete_retention_days" {
  type        = number
  description = "Number of days to retain soft-deleted blobs in the storage account. Soft delete protects blob data from accidental deletion by retaining deleted blobs for the specified period, allowing recovery if needed. Valid range: 1-365 days."
  default     = 7
}

variable "storage_account_blob_soft_delete_enabled" {
  type        = bool
  description = "Enable soft delete protection for blobs in the storage account. When enabled, deleted blobs are retained for the configured retention period and can be restored. Recommended for production environments to protect against accidental Terraform state deletion."
  default     = true
}

variable "storage_account_container_soft_delete_retention_days" {
  type        = number
  description = "Number of days to retain soft-deleted containers in the storage account. Soft delete protects container-level data from accidental deletion by retaining deleted containers for the specified period. Valid range: 1-365 days."
  default     = 7
}

variable "storage_account_container_soft_delete_enabled" {
  type        = bool
  description = "Enable soft delete protection for containers in the storage account. When enabled, deleted containers are retained for the configured retention period and can be restored. Provides an additional layer of protection for Terraform state storage."
  default     = true
}

variable "storage_account_blob_versioning_enabled" {
  type        = bool
  description = "Enable blob versioning for the storage account. When enabled, Azure automatically maintains previous versions of blobs, providing protection against accidental overwrites or deletions and enabling point-in-time recovery of Terraform state files."
  default     = true
}

variable "bicep_tenant_role_assignment_enabled" {
  type        = bool
  description = "Enable tenant-level role assignment for Bicep deployments. When enabled, assigns the specified role to the managed identity at the tenant root scope, allowing management of resources across the entire Azure AD tenant. Required for tenant-wide policy and management group operations."
  default     = true
}

variable "bicep_tenant_role_assignment_role_definition_name" {
  type        = string
  description = "The name of the Azure role definition to assign at the tenant level for Bicep deployments. This role grants the managed identity permissions to manage Azure Landing Zones resources across the tenant. Common values: 'Landing Zone Management Owner', 'Owner', or a custom role name."
  default     = "Landing Zone Management Owner"
}

variable "terraform_architecture_file_path" {
  description = <<-EOT
    **(Required)** Relative path to the Terraform architecture definition JSON file within the module folder.

    This file defines the structure and components of the Terraform deployment architecture.
    Used for dynamic file manipulation based on architecture specifics.
  EOT
  type        = string
  default     = "lib/architecture_definitions/alz_custom.alz_architecture_definition.yaml"
}
