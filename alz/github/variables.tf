variable "iac_type" {
  description = "The type of infrastructure as code to use for the deployment. (e.g. 'terraform' or `bicep)"
  type        = string
}

variable "module_folder_path" {
  description = "The folder for the starter modules"
  type        = string
}

variable "root_parent_management_group_id" {
  description = "The root parent management group ID. This will default to the Tenant Root Group ID if not supplied"
  type        = string
  default     = ""
}

variable "subscription_ids" {
  description = "The list of subscription IDs to deploy the Platform Landing Zones into"
  type        = map(string)
  default     = {}
  nullable    = false
  validation {
    condition     = length(var.subscription_ids) == 0 || alltrue([for id in values(var.subscription_ids) : can(regex("^[0-9a-fA-F-]{36}$", id))])
    error_message = "All subscription IDs must be valid GUIDs"
  }
  validation {
    condition     = length(var.subscription_ids) == 0 || alltrue([for id in keys(var.subscription_ids) : contains(["management", "connectivity", "identity", "security"], id)])
    error_message = "The keys of the subscription_ids map must be one of 'management', 'connectivity', 'identity' or 'security'"
  }
}

variable "subscription_id_connectivity" {
  description = "DEPRECATED (use subscription_ids instead): The identifier of the Connectivity Subscription"
  type        = string
  default     = null
  validation {
    condition     = var.subscription_id_connectivity == null || can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id_connectivity))
    error_message = "The bootstrap subscription ID must be a valid GUID"
  }
}

variable "subscription_id_identity" {
  description = "DEPRECATED (use subscription_ids instead): The identifier of the Identity Subscription"
  type        = string
  default     = null
  validation {
    condition     = var.subscription_id_identity == null || can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id_identity))
    error_message = "The bootstrap subscription ID must be a valid GUID"
  }
}

variable "subscription_id_management" {
  description = "DEPRECATED (use subscription_ids instead): The identifier of the Management Subscription"
  type        = string
  default     = null
  validation {
    condition     = var.subscription_id_management == null || can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id_management))
    error_message = "The bootstrap subscription ID must be a valid GUID"
  }
}

variable "configuration_file_path" {
  description = "The name of the configuration file"
  type        = string
  default     = ""
}

variable "starter_module_name" {
  description = "The name of the starter module"
  type        = string
  default     = ""
}

variable "on_demand_folder_repository" {
  description = "The repository to use for the on-demand folders"
  type        = string
  default     = ""
}

variable "on_demand_folder_artifact_name" {
  description = "The branch to use for the on-demand folders"
  type        = string
  default     = ""
}

variable "bootstrap_location" {
  description = "Azure Deployment location for the bootstrap resources (e.g. storage account, identities, etc)"
  type        = string
}

variable "github_personal_access_token" {
  description = "Personal access token for GitHub"
  type        = string
  sensitive   = true
}

variable "github_organization_scheme" {
  description = "The scheme of your GitHub organization. E.g. 'https' or 'http'"
  type        = string
  default     = "https"
  validation {
    condition     = can(regex("^(https|http)$", var.github_organization_scheme))
    error_message = "The scheme must be either 'https' or 'http'"
  }
}

variable "github_organization_domain_name" {
  description = "The domain name of your GitHub organization. E.g. 'my-enterprise.ghe.com'"
  type        = string
  default     = "github.com"
  validation {
    condition     = can(regex("^[a-zA-Z0-9.-]+$", var.github_organization_domain_name))
    error_message = "The domain name must only contain letters, numbers, dots, and dashes"
  }
}

variable "github_api_domain_name" {
  description = "The domain name of your GitHub api endpoint. E.g. 'api.my-enterprise.ghe.com'. This is only required if not using the default `api.` prefix"
  type        = string
  default     = ""
  validation {
    condition     = var.github_api_domain_name == "" || can(regex("^[a-zA-Z0-9.-]+$", var.github_api_domain_name))
    error_message = "The api domain name must only contain letters, numbers, dots, and dashes"
  }
}

variable "github_organization_name" {
  description = "The name of your GitHub organization. This is the section of the url after 'github.com'. E.g. enter 'my-org' for 'https://github.com/my-org'"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.github_organization_name))
    error_message = "The organization name must only contain letters, numbers, and dashes"
  }
}

variable "use_separate_repository_for_templates" {
  description = "Controls whether to use a separate repository to store action templates. This is an extra layer of security to ensure that the azure credentials can only be leveraged for the specified workload"
  type        = bool
  default     = true
}

variable "bootstrap_subscription_id" {
  description = "Azure Subscription ID for the bootstrap resources (e.g. storage account, identities, etc). Leave empty to use the az login subscription"
  type        = string
  default     = ""
  validation {
    condition     = var.bootstrap_subscription_id == "" ? true : can(regex("^[0-9a-fA-F-]{36}$", var.bootstrap_subscription_id))
    error_message = "The bootstrap subscription ID must be a valid GUID"
  }
}

variable "service_name" {
  description = "Used to build up the default resource names (e.g. rg-<service_name>-mgmt-uksouth-001)"
  type        = string
  default     = "alz"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.service_name))
    error_message = "The service name must only contain lowercase letters and numbers"
  }
}

variable "environment_name" {
  description = "Used to build up the default resource names (e.g. rg-alz-<environment_name>-uksouth-001)"
  type        = string
  default     = "mgmt"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.environment_name))
    error_message = "The environment name must only contain lowercase letters and numbers"
  }
}

variable "postfix_number" {
  description = "Used to build up the default resource names (e.g. rg-alz-mgmt-uksouth-<postfix_number>)"
  type        = number
  default     = 1
}

variable "use_self_hosted_runners" {
  description = "Controls whether to use self-hosted runners for the actions"
  type        = bool
  default     = true
}

variable "github_runners_personal_access_token" {
  description = "Personal access token for GitHub self-hosted runners (the token requires the 'repo' scope and should not expire). Only required if 'use_self_hosted_runners' is 'true'"
  type        = string
  sensitive   = true
  default     = ""
}

variable "use_private_networking" {
  description = "Controls whether to use private networking for the runner to storage account communication"
  type        = bool
  default     = true
}

variable "use_runner_group" {
  description = "Controls whether to use a runner group. This is only relevant if using a GitHub Enterprise licensed organization"
  type        = bool
  default     = true
}

variable "allow_storage_access_from_my_ip" {
  description = "Allow access to the storage account from the current IP address. We recommend this is kept off for security"
  type        = bool
  default     = false
}

variable "apply_approvers" {
  description = "Apply stage approvers to the action / pipeline, must be a list of emails or usernames separated by a comma (e.g. abcdef@microsoft.com,ghijklm@microsoft.com)"
  type        = list(string)
  default     = []
}

variable "apply_approval_team_creation_enabled" {
  description = "Controls whether to create a team for approvals."
  type        = bool
  default     = true
}

variable "apply_approval_existing_team_name" {
  description = "The name of an existing team to use for approvals. Only required if 'apply_approval_team_creation_enabled' is 'false'. If this is left null and `apply_approval_team_creation_enabled` is `false`, the module will not set any team for approvals."
  type        = string
  default     = null
}

variable "create_branch_policies" {
  description = "Controls whether to create branch policies for the repositories"
  type        = bool
  default     = true
}

variable "built_in_configuration_file_names" {
  description = "Built-in configuration file name"
  type        = list(string)
  default     = ["config.yaml", "config-hub-and-spoke-vnet.yaml", "config-virtual-wan.yaml"]
}

variable "module_folder_path_relative" {
  description = "Whether the module folder path is relative to the bootstrap module"
  type        = bool
  default     = false
}

variable "resource_names" {
  type = object({
    resource_group_state                                        = optional(string, "rg-{{service_name}}-{{environment_name}}-state-{{azure_location}}-{{postfix_number}}")
    resource_group_identity                                     = optional(string, "rg-{{service_name}}-{{environment_name}}-identity-{{azure_location}}-{{postfix_number}}")
    resource_group_agents                                       = optional(string, "rg-{{service_name}}-{{environment_name}}-agents-{{azure_location}}-{{postfix_number}}")
    resource_group_network                                      = optional(string, "rg-{{service_name}}-{{environment_name}}-network-{{azure_location}}-{{postfix_number}}")
    user_assigned_managed_identity_plan                         = optional(string, "id-{{service_name}}-{{environment_name}}-{{azure_location}}-plan-{{postfix_number}}")
    user_assigned_managed_identity_apply                        = optional(string, "id-{{service_name}}-{{environment_name}}-{{azure_location}}-apply-{{postfix_number}}")
    user_assigned_managed_identity_federated_credentials_prefix = optional(string, "{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}")
    storage_account                                             = optional(string, "sto{{service_name_short}}{{environment_name_short}}{{azure_location_short}}{{postfix_number}}{{random_string}}")
    storage_container                                           = optional(string, "{{environment_name}}-tfstate")
    container_instance_01                                       = optional(string, "aci-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}")
    container_instance_02                                       = optional(string, "aci-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number_plus_1}}")
    container_instance_managed_identity                         = optional(string, "id-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}-aci")
    runner_01                                                   = optional(string, "runner-{{service_name}}-{{environment_name}}-{{postfix_number}}")
    runner_02                                                   = optional(string, "runner-{{service_name}}-{{environment_name}}-{{postfix_number_plus_1}}")
    version_control_system_repository                           = optional(string, "{{service_name}}-{{environment_name}}")
    version_control_system_repository_templates                 = optional(string, "{{service_name}}-{{environment_name}}-templates")
    version_control_system_environment_plan                     = optional(string, "{{service_name}}-{{environment_name}}-plan")
    version_control_system_environment_apply                    = optional(string, "{{service_name}}-{{environment_name}}-apply")
    version_control_system_team                                 = optional(string, "{{service_name}}-{{environment_name}}-approvers")
    version_control_system_runner_group                         = optional(string, "{{service_name}}-{{environment_name}}")
    virtual_network                                             = optional(string, "vnet-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}")
    public_ip                                                   = optional(string, "pip-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}")
    nat_gateway                                                 = optional(string, "nat-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}")
    subnet_container_instances                                  = optional(string, "subnet-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}-aci")
    subnet_private_endpoints                                    = optional(string, "subnet-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}-pe")
    storage_account_private_endpoint                            = optional(string, "pe-{{service_name}}-{{environment_name}}-{{azure_location}}-sto-{{postfix_number}}")
    container_registry                                          = optional(string, "acr{{service_name}}{{environment_name}}{{azure_location_short}}{{postfix_number}}{{random_string}}")
    container_registry_private_endpoint                         = optional(string, "pe-{{service_name}}-{{environment_name}}-{{azure_location}}-acr-{{postfix_number}}")
    container_image_name                                        = optional(string, "github-runner")
  })
  description = "Overrides for resource names"
  default     = {}
}

variable "runner_container_image_repository" {
  description = "The container image repository to use for GitHub Runner"
  type        = string
  default     = "https://github.com/Azure/avm-container-images-cicd-agents-and-runners"
}

variable "runner_container_image_tag" {
  description = "The container image tag to use for GitHub Runner"
  type        = string
  default     = "39b9059"
}

variable "runner_container_image_folder" {
  description = "The folder containing the Dockerfile for the container image"
  type        = string
  default     = "github-runner-aci"
}

variable "runner_container_image_dockerfile" {
  description = "The Dockerfile to use for the container image"
  type        = string
  default     = "dockerfile"
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

variable "runner_container_zone_support" {
  description = "The container zone support"
  type        = bool
  default     = true
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

variable "virtual_network_subnet_address_prefix_private_endpoints" {
  type        = string
  description = "Address prefix for the virtual network subnet"
  default     = "10.0.0.64/26"
}

variable "additional_files" {
  description = "Additional files to upload to the repository. This must be specified as a comma-separated list of absolute file paths (e.g. c:\\config\\config.yaml or /home/user/config/config.yaml)"
  type        = list(string)
  default     = []
}

variable "additional_folders_path" {
  description = "Additional folders to upload to the repository. This must be specified as a comma-separated list of absolute paths (e.g. c:\\templates\\Microsoft_Cloud_for_Industry\\Common or /templates/Microsoft_Cloud_for_Industry/Common)"
  type        = list(string)
  default     = []
}

variable "storage_account_replication_type" {
  description = "Controls the redundancy for the storage account"
  type        = string
  default     = "ZRS"
}

variable "bicep_config_file_path" {
  type    = string
  default = ".config/ALZ-Powershell.config.json"
}

variable "bicep_parameters_file_path" {
  type    = string
  default = "parameters.json"
}

variable "custom_role_definitions_terraform" {
  description = "Custom role definitions to create for Terraform"
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
          "Microsoft.Management/managementGroups/settings/read",
          "Microsoft.Management/managementGroups/settings/write",
          "Microsoft.Management/managementGroups/settings/delete",
          "Microsoft.Management/managementGroups/write",
          "Microsoft.Management/managementGroups/subscriptions/read",
          "Microsoft.Authorization/policyDefinitions/write",
          "Microsoft.Authorization/policySetDefinitions/write",
          "Microsoft.Authorization/policyAssignments/write",
          "Microsoft.Authorization/roleDefinitions/write",
          "Microsoft.Authorization/*/read",
          "Microsoft.Authorization/roleAssignments/write",
          "Microsoft.Authorization/roleAssignments/delete",
          "Microsoft.Insights/diagnosticSettings/write"
        ]
        not_actions = []
      }
    }
    alz_management_group_reader = {
      name        = "Azure Landing Zones Management Group Reader ({{service_name}}-{{environment_name}})"
      description = "This is a custom role created by the Azure Landing Zones Accelerator for Reading the Management Group Structure."
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
          "Microsoft.Resources/deployments/write",
          "Microsoft.Resources/deploymentStacks/read",
          "Microsoft.Resources/deploymentStacks/validate/action"
        ]
        not_actions = []
      }
    }
    alz_subscription_owner = {
      name        = "Azure Landing Zones Subscription Owner ({{service_name}}-{{environment_name}})"
      description = "This is a custom role created by the Azure Landing Zones Accelerator for Writing in platform subscriptions."
      permissions = {
        actions = [
          "*"
        ]
        not_actions = []
      }
    }
    alz_subscription_reader = {
      name        = "Azure Landing Zones Subscription Reader ({{service_name}}-{{environment_name}})"
      description = "This is a custom role created by the Azure Landing Zones Accelerator for Reading the platform subscriptions."
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

variable "custom_role_definitions_bicep" {
  description = "Custom role definitions to create for Bicep"
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
      description = "This is a custom role created by the Azure Landing Zones Accelerator for creating and managing the Management Group hierarchy and its associated governance resources such as policy, RBAC etc..."
      permissions = {
        actions = [
          "*/read",
          "Microsoft.Management/*",
          "Microsoft.Authorization/*",
          "Microsoft.Resources/*",
          "Microsoft.Support/*",
          "Microsoft.Insights/diagnosticSettings/*"
        ]
        not_actions = [
          "Microsoft.Resources/subscriptions/resourceGroups/write",
          "Microsoft.Resources/subscriptions/resourceGroups/delete"
        ]
      }
    }
    alz_management_group_reader = {
      name        = "Azure Landing Zones Management Group What If ({{service_name}}-{{environment_name}})"
      description = "This is a custom role created by the Azure Landing Zones Accelerator for running Bicep What If for the Management Group hierarchy and its associated governance resources such as policy, RBAC etc... You must use the `--validation-level providerNoRbac` (Az CLI 2.75.0 or later) or `-ValidationLevel providerNoRbac` (Az PowerShell 13.4.0 or later (Az.Resources 7.10.0 or later)) flag when running Bicep What If with this role."
      permissions = {
        actions = [
          "*/read",
          "Microsoft.Resources/deployments/whatIf/action",
          "Microsoft.Resources/deployments/validate/action",
          "Microsoft.Resources/subscriptions/operationResults/read",
          "Microsoft.Management/operationResults/*/read"
        ]
        not_actions = []
      }
    }
    alz_subscription_owner = {
      name        = "Azure Landing Zones Subscription Owner ({{service_name}}-{{environment_name}})"
      description = "This is a custom role created by the Azure Landing Zones Accelerator for Writing in platform subscriptions."
      permissions = {
        actions = [
          "*"
        ]
        not_actions = []
      }
    }
    alz_subscription_reader = {
      name        = "Azure Landing Zones Subscription What If ({{service_name}}-{{environment_name}})"
      description = "This is a custom role created by the Azure Landing Zones Accelerator for running Bicep What If for the Management Group hierarchy and its associated governance resources such as policy, RBAC etc... You must use the `--validation-level providerNoRbac` (Az CLI 2.75.0 or later) or `-ValidationLevel providerNoRbac` (Az PowerShell 13.4.0 or later (Az.Resources 7.10.0 or later)) flag when running Bicep What If with this role."
      permissions = {
        actions = [
          "*/read",
          "Microsoft.Resources/deployments/whatIf/action",
          "Microsoft.Resources/deployments/validate/action",
          "Microsoft.Resources/subscriptions/operationResults/read",
          "Microsoft.Management/operationResults/*/read"
        ]
        not_actions = []
      }
    }
  }
}

variable "role_assignments_terraform" {
  description = "Role assignments to create for Terraform"
  type = map(object({
    custom_role_definition_key         = string
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

variable "role_assignments_bicep" {
  description = "Role assignments to create for Bicep"
  type = map(object({
    custom_role_definition_key         = string
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

variable "root_module_folder_relative_path" {
  type        = string
  description = "The root module folder path"
  default     = "."
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

variable "tenant_role_assignment_enabled" {
  type    = bool
  default = false
}

variable "tenant_role_assignment_role_definition_name" {
  type    = string
  default = "Landing Zone Management Owner"
}
