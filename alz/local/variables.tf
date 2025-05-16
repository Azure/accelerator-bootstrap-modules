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

variable "subscription_id_connectivity" {
  description = "The identifier of the Connectivity Subscription"
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id_connectivity))
    error_message = "The bootstrap subscription ID must be a valid GUID"
  }
}

variable "subscription_id_identity" {
  description = "The identifier of the Identity Subscription"
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id_identity))
    error_message = "The bootstrap subscription ID must be a valid GUID"
  }
}

variable "subscription_id_management" {
  description = "The identifier of the Management Subscription"
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id_management))
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

variable "bootstrap_location" {
  description = "Azure Deployment location for the bootstrap resources (e.g. storage account, identities, etc)"
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

variable "target_directory" {
  description = "The target directory to create the landing zone files in. (e.g. 'c:\\landingzones\\my_landing_zone')"
  type        = string
  default     = ""
}

variable "create_bootstrap_resources_in_azure" {
  description = "Whether to create resources in Azure (e.g. resource group, storage account, identities, etc.)"
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

variable "grant_permissions_to_current_user" {
  description = "Grant permissions to the current user on the bootstrap resources in addition to the user assinged managed identities."
  type        = bool
  default     = true
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
  type        = map(string)
  description = "Overrides for resource names"
  default = {
    resource_group_state                                        = "rg-{{service_name}}-{{environment_name}}-state-{{azure_location}}-{{postfix_number}}"
    resource_group_identity                                     = "rg-{{service_name}}-{{environment_name}}-identity-{{azure_location}}-{{postfix_number}}"
    user_assigned_managed_identity_plan                         = "id-{{service_name}}-{{environment_name}}-{{azure_location}}-plan-{{postfix_number}}"
    user_assigned_managed_identity_apply                        = "id-{{service_name}}-{{environment_name}}-{{azure_location}}-apply-{{postfix_number}}"
    user_assigned_managed_identity_federated_credentials_prefix = "{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}"
    storage_account                                             = "sto{{service_name_short}}{{environment_name_short}}{{azure_location_short}}{{postfix_number}}{{random_string}}"
    storage_container                                           = "{{environment_name}}-tfstate"
  }
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
  default     = "../../../../local-output"
}

variable "storage_account_replication_type" {
  description = "Controls the redundancy for the storage account"
  type        = string
  default     = "ZRS"
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
    alz_managment_group_contributor = {
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
          "Microsoft.Resources/deployments/write",
          "Microsoft.Resources/deployments/exportTemplate/action",
          "Microsoft.Authorization/roleAssignments/write",
          "Microsoft.Authorization/roleAssignments/delete",
          "Microsoft.Insights/diagnosticSettings/write"
        ]
        not_actions = []
      }
    }
    alz_managment_group_reader = {
      name        = "Azure Landing Zones Management Group Reader ({{service_name}}-{{environment_name}})"
      description = "This is a custom role created by the Azure Landing Zones Accelerator for Reading the Management Group Structure."
      permissions = {
        actions = [
          "Microsoft.Management/managementGroups/read",
          "Microsoft.Management/managementGroups/subscriptions/read",
          "Microsoft.Management/managementGroups/settings/read",
          "Microsoft.Authorization/*/read",
          "Microsoft.Resources/deployments/write",
          "Microsoft.Resources/deployments/exportTemplate/action"
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
          "Microsoft.Resources/deployments/write",
          "Microsoft.Resources/deployments/exportTemplate/action"
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
          "Microsoft.Resources/deployments/write",
          "Microsoft.Resources/deployments/exportTemplate/action"
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
    alz_managment_group_contributor = {
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
    alz_managment_group_reader = {
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
  description = "Role assignments to create for Terraform"
  type = map(object({
    custom_role_definition_key         = string
    user_assigned_managed_identity_key = string
    scope                              = string
  }))
  default = {
    plan_management_group = {
      custom_role_definition_key         = "alz_managment_group_reader"
      user_assigned_managed_identity_key = "plan"
      scope                              = "management_group"
    }
    apply_management_group = {
      custom_role_definition_key         = "alz_managment_group_contributor"
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
      custom_role_definition_key         = "alz_managment_group_reader"
      user_assigned_managed_identity_key = "plan"
      scope                              = "management_group"
    }
    apply_management_group = {
      custom_role_definition_key         = "alz_managment_group_contributor"
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
  type    = string
  default = "accelerator/.config/ALZ-Powershell-Auto.config.json"
}

variable "bicep_parameters_file_path" {
  type    = string
  default = "parameters.json"
}

variable "architecture_definition_name" {
  type        = string
  description = "Name of the architecture definition use by Microsoft Cloud for Industry"
  default     = null
}

variable "root_module_folder_relative_path" {
  type        = string
  description = "The root module folder path"
  default     = "."
}

variable "architecture_definition_template_path" {
  type        = string
  default     = ""
  description = "The path to the architecture definition template file to use."
}

variable "architecture_definition_override_path" {
  type        = string
  default     = ""
  description = "The path to the architecture definition file to use instead of the default."
}

variable "apply_alz_archetypes_via_architecture_definition_template" {
  type        = bool
  default     = true
  description = "Toggles assignment of ALZ policies. True to deploy, otherwise false. (e.g true)"
}
