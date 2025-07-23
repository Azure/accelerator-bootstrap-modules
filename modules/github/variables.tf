variable "domain_name" {
  type = string
}

variable "organization_name" {
  type = string
}

variable "repository_name" {
  type = string
}

variable "repository_files" {
  type = map(object({
    content = string
  }))
}

variable "template_repository_files" {
  type = map(object({
    content = string
  }))
}

variable "environments" {
  type = map(string)
}

variable "managed_identity_client_ids" {
  type = map(string)
}

variable "azure_tenant_id" {
  type = string
}

variable "azure_subscription_id" {
  type = string
}

variable "backend_azure_resource_group_name" {
  type = string
}

variable "backend_azure_storage_account_name" {
  type = string
}

variable "backend_azure_storage_account_container_name" {
  type = string
}

variable "approvers" {
  type = list(string)
}

variable "create_team" {
  type = bool
}

variable "existing_team_name" {
  type = string
}

variable "team_name" {
  type = string
}

variable "use_template_repository" {
  type = bool
}

variable "repository_name_templates" {
  type = string
}

variable "workflows" {
  type = map(object({
    workflow_file_name = string
    environment_user_assigned_managed_identity_mappings = list(object({
      environment_key                    = string
      user_assigned_managed_identity_key = string
    }))
  }))
}

variable "runner_group_name" {
  type = string
}

variable "default_runner_group_name" {
  type = string
}

variable "use_runner_group" {
  type = bool
}

variable "use_self_hosted_runners" {
  type = bool
}

variable "create_branch_policies" {
  type = bool
}
