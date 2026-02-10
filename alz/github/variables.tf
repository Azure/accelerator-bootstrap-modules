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
    **(Optional, default: `""`)** The root parent management group ID.

    If not supplied, defaults to the Tenant Root Group ID.
  EOT
  type        = string
  default     = ""
}

variable "subscription_ids" {
  description = <<-EOT
    **(Optional, default: `{}`)** Map of Azure subscription IDs where Platform Landing Zone resources will be deployed.

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

variable "bootstrap_location" {
  description = <<-EOT
    **(Required)** The Azure region where bootstrap resources will be deployed.

    Specifies the location for storage accounts, managed identities, and other bootstrap resources.
    Examples: 'uksouth', 'eastus', 'westeurope'
  EOT
  type        = string
}

variable "github_personal_access_token" {
  description = <<-EOT
    **(Required)** Personal access token for GitHub authentication.

    This token is used to authenticate and manage GitHub resources.
    Requires appropriate scopes for repository and workflow management.
  EOT
  type        = string
  sensitive   = true
}

variable "github_organization_scheme" {
  description = <<-EOT
    **(Optional, default: `"https"`)** The URL scheme for your GitHub organization.

    Valid values: 'https' or 'http'
  EOT
  type        = string
  default     = "https"
  validation {
    condition     = can(regex("^(https|http)$", var.github_organization_scheme))
    error_message = "The scheme must be either 'https' or 'http'"
  }
}

variable "github_organization_domain_name" {
  description = <<-EOT
    **(Optional, default: `"github.com"`)** The domain name of your GitHub organization.

    For GitHub Enterprise, use your custom domain (e.g., 'my-enterprise.ghe.com').
    For standard GitHub, use the default 'github.com'.
  EOT
  type        = string
  default     = "github.com"
  validation {
    condition     = can(regex("^[a-zA-Z0-9.-]+$", var.github_organization_domain_name))
    error_message = "The domain name must only contain letters, numbers, dots, and dashes"
  }
}

variable "github_api_domain_name" {
  description = <<-EOT
    **(Optional, default: `""`)** The domain name of your GitHub API endpoint.

    Only required for GitHub Enterprise if not using the default 'api.' prefix.
    Example: 'api.my-enterprise.ghe.com'
  EOT
  type        = string
  default     = ""
  validation {
    condition     = var.github_api_domain_name == "" || can(regex("^[a-zA-Z0-9.-]+$", var.github_api_domain_name))
    error_message = "The api domain name must only contain letters, numbers, dots, and dashes"
  }
}

variable "github_organization_name" {
  description = <<-EOT
    **(Required)** The name of your GitHub organization.

    This is the section of the URL after 'github.com'.
    Example: enter 'my-org' for 'https://github.com/my-org'
  EOT
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.github_organization_name))
    error_message = "The organization name must only contain letters, numbers, and dashes"
  }
}

variable "use_separate_repository_for_templates" {
  description = <<-EOT
    **(Optional, default: `true`)** Whether to use a separate repository for action templates.

    This provides an extra layer of security to ensure that Azure credentials can only be leveraged
    for the specified workload and not across all repositories.
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
    **(Optional, default: `"alz"`)** Used to build up the default resource names.

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
    **(Optional, default: `1`)** Used to build up the default resource names.

    Example: rg-alz-mgmt-uksouth-**<postfix_number>**
  EOT
  type        = number
  default     = 1
}

variable "use_self_hosted_runners" {
  description = <<-EOT
    **(Optional, default: `true`)** Whether to use self-hosted runners for GitHub Actions.

    When true, provisions container instances to run GitHub Actions runners.
    When false, uses GitHub-hosted runners.
  EOT
  type        = bool
  default     = true
}

variable "github_runners_personal_access_token" {
  description = <<-EOT
    **(Optional, default: `""`)** Personal access token for GitHub self-hosted runners.

    Required only if 'use_self_hosted_runners' is true.
    The token requires the 'repo' scope and should have the maximum expiry.
  EOT
  type        = string
  sensitive   = true
  default     = ""
}

variable "use_private_networking" {
  description = <<-EOT
    **(Optional, default: `true`)** Whether to use private networking for runner-to-storage communication.

    When true, configures private endpoints for secure communication between runners and storage accounts.
  EOT
  type        = bool
  default     = true
}

variable "use_runner_group" {
  description = <<-EOT
    **(Optional, default: `true`)** Whether to use a runner group.

    This is only relevant for GitHub Enterprise licensed organizations.
  EOT
  type        = bool
  default     = true
}

variable "allow_storage_access_from_my_ip" {
  description = <<-EOT
    **(Optional, default: `false`)** Allow access to the storage account from the current IP address.

    We recommend this is kept off for security.
  EOT
  type        = bool
  default     = false
}

variable "apply_approvers" {
  description = <<-EOT
    **(Optional, default: `[]`)** List of approvers for the apply stage in GitHub Actions.

    Must be a list of GitHub usernames or team slugs.
    Example: ["user1", "user2", "org/team-name"]
  EOT
  type        = list(string)
  default     = []
}

variable "apply_approval_team_creation_enabled" {
  description = <<-EOT
    **(Optional, default: `true`)** Whether to create a GitHub team for approvals.

    When true, automatically creates a team to manage approval workflows.
  EOT
  type        = bool
  default     = true
}

variable "apply_approval_existing_team_name" {
  description = <<-EOT
    **(Optional, default: `null`)** The name of an existing GitHub team to use for approvals.

    Only required if 'apply_approval_team_creation_enabled' is false.
    If null and team creation is disabled, no team will be set for approvals.
  EOT
  type        = string
  default     = null
}

variable "create_branch_policies" {
  description = <<-EOT
    **(Optional, default: `true`)** Whether to create branch protection rules for the repositories.

    When true, configures branch protection policies for the main branch.
  EOT
  type        = bool
  default     = true
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
    - `{{postfix_number_plus_1}}` - Replaced with postfix_number + 1
    - `{{random_string}}` - Replaced with generated random string
    - `{{service_name_short}}`, `{{environment_name_short}}`, `{{azure_location_short}}` - Shortened versions

    Object fields include:
    - Resource groups: `resource_group_state`, `resource_group_identity`, `resource_group_agents`, `resource_group_network`
    - Managed identities: `user_assigned_managed_identity_plan`, `user_assigned_managed_identity_apply`, `user_assigned_managed_identity_federated_credentials_prefix`
    - Storage: `storage_account`, `storage_container`
    - Container instances: `container_instance_01`, `container_instance_02`, `container_instance_managed_identity`
    - Runners: `runner_01`, `runner_02`
    - GitHub resources: `version_control_system_*` for repositories, environments, team, runner group
    - Networking: `virtual_network`, `public_ip`, `nat_gateway`, subnets, private endpoints
    - Container registry: `container_registry`, `container_registry_private_endpoint`, `container_image_name`

    All fields are optional and use default templates if not specified.
  EOT
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
  default = {}
}

variable "runner_container_image_repository" {
  description = <<-EOT
    **(Optional, default: `"https://github.com/Azure/avm-container-images-cicd-agents-and-runners"`)**
    The Git repository URL containing the container image for GitHub runners.
  EOT
  type        = string
  default     = "https://github.com/Azure/avm-container-images-cicd-agents-and-runners"
}

variable "runner_container_image_tag" {
  description = <<-EOT
    **(Optional, default: `"39b9059"`)** The container image tag/commit hash for GitHub runners.
  EOT
  type        = string
  default     = "57a937f"
}

variable "runner_container_image_folder" {
  description = <<-EOT
    **(Optional, default: `"github-runner-aci"`)** The folder containing the Dockerfile for the container image.
  EOT
  type        = string
  default     = "github-runner-aci"
}

variable "runner_container_image_dockerfile" {
  description = <<-EOT
    **(Optional, default: `"Dockerfile"`)** The Dockerfile name to use for the container image.
  EOT
  type        = string
  default     = "Dockerfile"
}

variable "runner_container_cpu" {
  description = <<-EOT
    **(Optional, default: `2`)** Default CPU cores allocated to each GitHub self-hosted runner container instance.

    Specified in number of cores (e.g., 1, 2, 4). Adjust based on workflow workload requirements.
  EOT
  type        = number
  default     = 2
}

variable "runner_container_memory" {
  description = <<-EOT
    **(Optional, default: `4`)** Default memory (in GB) allocated to each GitHub self-hosted runner container instance.

    Adjust based on workflow memory requirements and workload complexity.
  EOT
  type        = number
  default     = 4
}

variable "runner_container_cpu_max" {
  description = <<-EOT
    **(Optional, default: `2`)** Maximum CPU cores that can be allocated to GitHub runner containers under heavy load.

    Used for container bursting capabilities to handle peak workflow execution demands.
  EOT
  type        = number
  default     = 2
}

variable "runner_container_memory_max" {
  description = <<-EOT
    **(Optional, default: `4`)** Maximum memory (in GB) that can be allocated to GitHub runner containers under heavy load.

    Used for container bursting capabilities during intensive workflow operations.
  EOT
  type        = number
  default     = 4
}

variable "runner_container_zone_support" {
  description = <<-EOT
    **(Optional, default: `true`)** Enable availability zone support for GitHub runner container instances.

    When enabled, containers are distributed across availability zones for higher availability and resilience.
    Some regions do not support availability zones, in which case this should be set to false.
  EOT
  type        = bool
  default     = true
}

variable "container_registry_zone_redundancy_enabled" {
  description = <<-EOT
    **(Optional, default: `null`)** Enable zone redundancy for the Azure Container Registry.

    When enabled, the container registry is replicated across availability zones for higher availability.
    Some regions do not support zone redundancy, in which case this should be set to false.
    Defaults to the value of `runner_container_zone_support` if not set.
  EOT
  type        = bool
  default     = null
}

variable "runner_name_environment_variable" {
  description = <<-EOT
    **(Optional, default: `"GH_RUNNER_NAME"`)** The runner name environment variable supplied to the container.
  EOT
  type        = string
  default     = "GH_RUNNER_NAME"
}

variable "runner_group_environment_variable" {
  description = <<-EOT
    **(Optional, default: `"GH_RUNNER_GROUP"`)** The runner group environment variable supplied to the container.
  EOT
  type        = string
  default     = "GH_RUNNER_GROUP"
}

variable "runner_organization_environment_variable" {
  description = <<-EOT
    **(Optional, default: `"GH_RUNNER_URL"`)** The runner organization URL environment variable supplied to the container.
  EOT
  type        = string
  default     = "GH_RUNNER_URL"
}

variable "runner_token_environment_variable" {
  description = <<-EOT
    **(Optional, default: `"GH_RUNNER_TOKEN"`)** The runner token environment variable supplied to the container.
  EOT
  type        = string
  default     = "GH_RUNNER_TOKEN"
}

variable "default_runner_group_name" {
  description = <<-EOT
    **(Optional, default: `"Default"`)** The default runner group name for unlicensed organizations.
  EOT
  type        = string
  default     = "Default"
}

variable "virtual_network_address_space" {
  description = <<-EOT
    **(Optional, default: `"10.0.0.0/24"`)** The address space for the virtual network.
  EOT
  type        = string
  default     = "10.0.0.0/24"
}

variable "virtual_network_subnet_address_prefix_container_instances" {
  description = <<-EOT
    **(Optional, default: `"10.0.0.0/26"`)** Address prefix for the container instances subnet.
  EOT
  type        = string
  default     = "10.0.0.0/26"
}

variable "virtual_network_subnet_address_prefix_private_endpoints" {
  description = <<-EOT
    **(Optional, default: `"10.0.0.64/26"`)** Address prefix for the private endpoints subnet.
  EOT
  type        = string
  default     = "10.0.0.64/26"
}

variable "additional_files" {
  description = <<-EOT
    **(Optional, default: `[]`)** Additional files to upload to the repository.

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
    **(Optional, default: `[]`)** Additional folders to upload to the repository.

    Must be specified as a list of absolute directory paths.
    Examples:
    - Windows: ["c:\\templates\\Microsoft_Cloud_for_Industry\\Common"]
    - Linux/Mac: ["/templates/Microsoft_Cloud_for_Industry/Common"]
  EOT
  type        = list(string)
  default     = []
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

variable "root_module_folder_relative_path" {
  description = <<-EOT
    **(Optional, default: `"."`)** The relative path from output directory to the root module folder.

    Used to establish correct path references in generated deployment scripts and GitHub Actions workflows.
    The root module folder contains the main Terraform or Bicep configuration.
  EOT
  type        = string
  default     = "."
}

variable "storage_account_blob_soft_delete_retention_days" {
  description = <<-EOT
    **(Optional, default: `7`)** Number of days to retain soft-deleted blobs in the storage account.

    Soft delete protects blob data from accidental deletion by retaining deleted blobs for the specified period,
    allowing recovery if needed. Valid range: 1-365 days.
  EOT
  type        = number
  default     = 7
}

variable "storage_account_blob_soft_delete_enabled" {
  description = <<-EOT
    **(Optional, default: `true`)** Enable soft delete protection for blobs in the storage account.

    When enabled, deleted blobs are retained for the configured retention period and can be restored.
    Recommended for production environments to protect against accidental Terraform state deletion.
  EOT
  type        = bool
  default     = true
}

variable "storage_account_container_soft_delete_retention_days" {
  description = <<-EOT
    **(Optional, default: `7`)** Number of days to retain soft-deleted containers in the storage account.

    Soft delete protects container-level data from accidental deletion by retaining deleted containers
    for the specified period. Valid range: 1-365 days.
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
    against accidental overwrites or deletions and enabling point-in-time recovery of Terraform state files.
  EOT
  type        = bool
  default     = true
}

variable "bicep_tenant_role_assignment_enabled" {
  description = <<-EOT
    **(Optional, default: `true`)** Enable tenant-level role assignment for Bicep deployments.

    When enabled, assigns the specified role to the managed identity at the tenant root scope,
    allowing management of resources across the entire Azure AD tenant.
    Required for tenant-wide policy and management group operations.
  EOT
  type        = bool
  default     = true
}

variable "bicep_tenant_role_assignment_role_definition_name" {
  description = <<-EOT
    **(Optional, default: `"Landing Zone Management Owner"`)** The Azure role definition name for tenant-level assignment.

    This role grants the managed identity permissions to manage Azure Landing Zones resources across the tenant.
    Common values: 'Landing Zone Management Owner', 'Owner', or a custom role name.
  EOT
  type        = string
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
