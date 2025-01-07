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
    resource_group_agents                                       = "rg-{{service_name}}-{{environment_name}}-agents-{{azure_location}}-{{postfix_number}}"
    resource_group_network                                      = "rg-{{service_name}}-{{environment_name}}-network-{{azure_location}}-{{postfix_number}}"
    user_assigned_managed_identity_plan                         = "id-{{service_name}}-{{environment_name}}-{{azure_location}}-plan-{{postfix_number}}"
    user_assigned_managed_identity_apply                        = "id-{{service_name}}-{{environment_name}}-{{azure_location}}-apply-{{postfix_number}}"
    user_assigned_managed_identity_federated_credentials_prefix = "{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}"
    storage_account                                             = "sto{{service_name_short}}{{environment_name_short}}{{azure_location_short}}{{postfix_number}}{{random_string}}"
    storage_container                                           = "{{environment_name}}-tfstate"
    container_instance_01                                       = "aci-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}"
    container_instance_02                                       = "aci-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number_plus_1}}"
    container_instance_managed_identity                         = "id-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}-aci"
    runner_01                                                   = "runner-{{service_name}}-{{environment_name}}-{{postfix_number}}"
    runner_02                                                   = "runner-{{service_name}}-{{environment_name}}-{{postfix_number_plus_1}}"
    version_control_system_repository                           = "{{service_name}}-{{environment_name}}"
    version_control_system_repository_templates                 = "{{service_name}}-{{environment_name}}-templates"
    version_control_system_environment_plan                     = "{{service_name}}-{{environment_name}}-plan"
    version_control_system_environment_apply                    = "{{service_name}}-{{environment_name}}-apply"
    version_control_system_team                                 = "{{service_name}}-{{environment_name}}-approvers"
    version_control_system_runner_group                         = "{{service_name}}-{{environment_name}}"
    virtual_network                                             = "vnet-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}"
    public_ip                                                   = "pip-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}"
    nat_gateway                                                 = "nat-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}"
    subnet_container_instances                                  = "subnet-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}-aci"
    subnet_private_endpoints                                    = "subnet-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}-pe"
    storage_account_private_endpoint                            = "pe-{{service_name}}-{{environment_name}}-{{azure_location}}-sto-{{postfix_number}}"
    container_registry                                          = "acr{{service_name}}{{environment_name}}{{azure_location_short}}{{postfix_number}}{{random_string}}"
    container_registry_private_endpoint                         = "pe-{{service_name}}-{{environment_name}}-{{azure_location}}-acr-{{postfix_number}}"
    container_image_name                                        = "github-runner"
  }
}

variable "runner_container_image_repository" {
  description = "The container image repository to use for GitHub Runner"
  type        = string
  default     = "https://github.com/Azure/terraform-azurerm-avm-ptn-cicd-agents-and-runners"
}

variable "runner_container_image_tag" {
  description = "The container image tag to use for GitHub Runner"
  type        = string
  default     = "8ff4b85"
}

variable "runner_container_image_folder" {
  description = "The folder containing the Dockerfile for the container image"
  type        = string
  default     = "container-images/github-runner"
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
  default     = "GZRS"
  validation {
    condition     = var.storage_account_replication_type == "ZRS" || var.storage_account_replication_type == "GZRS" || var.storage_account_replication_type == "RAGZRS"
    error_message = "Invalid storage account replication type. Valid values are ZRS, GZRS and RAGZRS."
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
