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
  default     = "GZRS"
  validation {
    condition     = var.storage_account_replication_type == "ZRS" || var.storage_account_replication_type == "GZRS" || var.storage_account_replication_type == "RAGZRS"
    error_message = "Invalid storage account replication type. Valid values are ZRS, GZRS and RAGZRS."
  }
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
          "Microsoft.Authorization/*/read",
          "Microsoft.Resources/deployments/write",
          "Microsoft.Resources/deployments/exportTemplate/action"
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
          "Microsoft.Authorization/*/read",
          "Microsoft.Resources/deployments/write",
          "Microsoft.Resources/deployments/exportTemplate/action"
        ]
        not_actions = []
      }
    }
    alz_subscription_owner = {
      name        = "Azure Landing Zones Subscription Owner ({{service_name}}-{{environment_name}})"
      description = "This is a custom role created by the Azure Landing Zones Accelerator for Writing in platfrom subscriptions."
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
      description = "This is a custom role created by the Azure Landing Zones Accelerator for Writing in platfrom subscriptions."
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
