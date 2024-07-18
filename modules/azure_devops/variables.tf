variable "use_legacy_organization_url" {
  type = bool
}

variable "organization_name" {
  type = string
}

variable "create_project" {
  type = bool
}

variable "project_name" {
  type = string
}

variable "environments" {
  type = map(object({
    environment_name                      = string
    service_connection_name               = string
    service_connection_required_templates = list(string)
  }))
}

variable "pipelines" {
  type = map(object({
    pipeline_name           = string
    pipeline_file_name      = string
    environment_keys        = list(string)
    service_connection_keys = list(string)
  }))
}

variable "managed_identity_client_ids" {
  type = map(string)
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

variable "variable_group_name" {
  type = string
}

variable "azure_tenant_id" {
  type = string
}

variable "azure_subscription_id" {
  type = string
}

variable "azure_subscription_name" {
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

variable "group_name" {
  type = string
}

variable "use_template_repository" {
  type = bool
}

variable "repository_name_templates" {
  type = string
}

variable "agent_pool_name" {
  type = string
}

variable "use_self_hosted_agents" {
  type = bool
}

variable "create_branch_policies" {
  type = bool
}
