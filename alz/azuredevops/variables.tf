variable "iac_type" {
  description = "The type of infrastructure as code to use for the deployment. (e.g. 'terraform' or 'bicep')"
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

variable "azure_devops_personal_access_token" {
  description = "The personal access token for Azure DevOps"
  type        = string
  sensitive   = true
}

variable "azure_devops_organization_name" {
  description = "The name of your Azure DevOps organization. This is the section of the url after 'dev.azure.com' or before '.visualstudio.com'. E.g. enter 'my-org' for 'https://dev.azure.com/my-org'"
  type        = string
}

variable "use_separate_repository_for_templates" {
  description = "Controls whether to use a separate repository to store pipeline templates. This is an extra layer of security to ensure that the azure credentials can only be leveraged for the specified workload"
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

variable "azure_devops_use_organisation_legacy_url" {
  description = "Use the legacy Azure DevOps URL (<organisation>.visualstudio.com) instead of the new URL (dev.azure.com/<organization>). This is ignored if an fqdn is supplied for version_control_system_organization"
  type        = bool
  default     = false
}

variable "azure_devops_create_project" {
  description = "Create the Azure DevOps project if it does not exist"
  type        = bool
  default     = true
}

variable "azure_devops_project_name" {
  description = "The name of the Azure DevOps project to use or create for the deployment"
  type        = string
}

variable "use_self_hosted_agents" {
  description = "Controls whether to use self-hosted agents for the pipelines"
  type        = bool
  default     = true
}

variable "azure_devops_agents_personal_access_token" {
  description = "Personal access token for Azure DevOps self-hosted agents (the token requires the 'Agent Pools - Read & Manage' scope and should have the maximum expiry). Only required if 'use_self_hosted_runners' is 'true'"
  type        = string
  sensitive   = true
  default     = ""
}

variable "use_private_networking" {
  description = "Controls whether to use private networking for the agent to storage account communication"
  type        = bool
  default     = true
}

variable "allow_storage_access_from_my_ip" {
  description = "Allow access to the storage account from the current IP address. We recommend this is kept off for security"
  type        = bool
  default     = false
}

variable "apply_approvers" {
  description = "Apply stage approvers to the action / pipeline, must be a list of SPNs separate by a comma (e.g. abcdef@microsoft.com,ghijklm@microsoft.com)"
  type        = list(string)
  default     = []
}

variable "create_branch_policies" {
  description = "Controls whether to create branch policies for the repositories"
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

variable "agent_container_image_repository" {
  description = "The container image repository to use for Azure DevOps Agents"
  type        = string
  default     = "https://github.com/Azure/avm-container-images-cicd-agents-and-runners"
}

variable "agent_container_image_tag" {
  description = "The container image tag to use for Azure DevOps Agents"
  type        = string
  default     = "39b9059"
}

variable "agent_container_image_folder" {
  description = "The folder containing the Dockerfile for the container image"
  type        = string
  default     = "azure-devops-agent-aci"
}

variable "agent_container_image_dockerfile" {
  description = "The Dockerfile to use for the container image"
  type        = string
  default     = "dockerfile"
}

variable "agent_container_cpu" {
  description = "The container cpu default"
  type        = number
  default     = 2
}

variable "agent_container_memory" {
  description = "The container memory default"
  type        = number
  default     = 4
}

variable "agent_container_cpu_max" {
  description = "The container cpu default"
  type        = number
  default     = 2
}

variable "agent_container_memory_max" {
  description = "The container memory default"
  type        = number
  default     = 4
}

variable "agent_container_zone_support" {
  description = "The container zone support"
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
  type        = map(string)
  description = "Overrides for resource names"
  default = {
    resource_group_state                                       = "rg-{{service_name}}-{{environment_name}}-state-{{azure_location}}-{{postfix_number}}"
    resource_group_identity                                    = "rg-{{service_name}}-{{environment_name}}-identity-{{azure_location}}-{{postfix_number}}"
    resource_group_agents                                      = "rg-{{service_name}}-{{environment_name}}-agents-{{azure_location}}-{{postfix_number}}"
    resource_group_network                                     = "rg-{{service_name}}-{{environment_name}}-network-{{azure_location}}-{{postfix_number}}"
    user_assigned_managed_identity_plan                        = "id-{{service_name}}-{{environment_name}}-{{azure_location}}-plan-{{postfix_number}}"
    user_assigned_managed_identity_apply                       = "id-{{service_name}}-{{environment_name}}-{{azure_location}}-apply-{{postfix_number}}"
    user_assigned_managed_identity_federated_credentials_plan  = "id-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}-plan"
    user_assigned_managed_identity_federated_credentials_apply = "id-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}-apply"
    storage_account                                            = "sto{{service_name_short}}{{environment_name_short}}{{azure_location_short}}{{postfix_number}}{{random_string}}"
    storage_container                                          = "{{environment_name}}-tfstate"
    container_instance_01                                      = "aci-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}"
    container_instance_02                                      = "aci-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number_plus_1}}"
    container_instance_managed_identity                        = "id-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}-aci"
    agent_01                                                   = "agent-{{service_name}}-{{environment_name}}-{{postfix_number}}"
    agent_02                                                   = "agent-{{service_name}}-{{environment_name}}-{{postfix_number_plus_1}}"
    version_control_system_repository                          = "{{service_name}}-{{environment_name}}"
    version_control_system_repository_templates                = "{{service_name}}-{{environment_name}}-templates"
    version_control_system_service_connection_plan             = "sc-{{service_name}}-{{environment_name}}-plan"
    version_control_system_service_connection_apply            = "sc-{{service_name}}-{{environment_name}}-apply"
    version_control_system_environment_plan                    = "{{service_name}}-{{environment_name}}-plan"
    version_control_system_environment_apply                   = "{{service_name}}-{{environment_name}}-apply"
    version_control_system_variable_group                      = "{{service_name}}-{{environment_name}}"
    version_control_system_agent_pool                          = "{{service_name}}-{{environment_name}}"
    version_control_system_group                               = "{{service_name}}-{{environment_name}}-approvers"
    version_control_system_pipeline_name_ci                    = "01 Azure Landing Zones Continuous Integration"
    version_control_system_pipeline_name_cd                    = "02 Azure Landing Zones Continuous Delivery"
    virtual_network                                            = "vnet-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}"
    public_ip                                                  = "pip-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}"
    nat_gateway                                                = "nat-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}"
    subnet_container_instances                                 = "subnet-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}-aci"
    subnet_private_endpoints                                   = "subnet-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}-pe"
    storage_account_private_endpoint                           = "pe-{{service_name}}-{{environment_name}}-{{azure_location}}-sto-{{postfix_number}}"
    container_registry                                         = "acr{{service_name}}{{environment_name}}{{azure_location_short}}{{postfix_number}}{{random_string}}"
    container_registry_private_endpoint                        = "pe-{{service_name}}-{{environment_name}}-{{azure_location}}-acr-{{postfix_number}}"
    container_image_name                                       = "azure-devops-agent"
  }
}

variable "agent_name_environment_variable" {
  description = "The agent name environment variable supplied to the container"
  type        = string
  default     = "AZP_AGENT_NAME"
}

variable "agent_pool_environment_variable" {
  description = "The agent pool environment variable supplied to the container"
  type        = string
  default     = "AZP_POOL"
}

variable "agent_organization_environment_variable" {
  description = "The agent organization environment variable supplied to the container"
  type        = string
  default     = "AZP_URL"
}

variable "agent_token_environment_variable" {
  description = "The agent token environment variable supplied to the container"
  type        = string
  default     = "AZP_TOKEN"
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

variable "storage_account_replication_type" {
  description = "Controls the redundancy for the storage account"
  type        = string
  default     = "ZRS"
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
