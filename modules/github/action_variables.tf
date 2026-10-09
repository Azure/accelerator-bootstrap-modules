resource "github_actions_environment_variable" "azure_plan_client_id" {
  for_each      = var.environments
  repository    = github_repository.alz.name
  environment   = github_repository_environment.alz[each.key].environment
  variable_name = "AZURE_CLIENT_ID"
  value         = var.managed_identity_client_ids[each.key]
}

resource "github_actions_variable" "azure_subscription_id" {
  repository    = github_repository.alz.name
  variable_name = "AZURE_SUBSCRIPTION_ID"
  value         = var.azure_subscription_id
}

resource "github_actions_variable" "azure_tenant_id" {
  repository    = github_repository.alz.name
  variable_name = "AZURE_TENANT_ID"
  value         = var.azure_tenant_id
}

resource "github_actions_variable" "backend_azure_resource_group_name" {
  count         = var.create_storage_account_variables ? 1 : 0
  repository    = github_repository.alz.name
  variable_name = "BACKEND_AZURE_RESOURCE_GROUP_NAME"
  value         = var.backend_azure_resource_group_name
}

resource "github_actions_variable" "backend_azure_storage_account_name" {
  count         = var.create_storage_account_variables ? 1 : 0
  repository    = github_repository.alz.name
  variable_name = "BACKEND_AZURE_STORAGE_ACCOUNT_NAME"
  value         = var.backend_azure_storage_account_name
}

resource "github_actions_variable" "backend_azure_storage_account_container_name" {
  count         = var.create_storage_account_variables ? 1 : 0
  repository    = github_repository.alz.name
  variable_name = "BACKEND_AZURE_STORAGE_ACCOUNT_CONTAINER_NAME"
  value         = var.backend_azure_storage_account_container_name
}

resource "github_actions_variable" "use_storage_account_for_plan" {
  count         = var.create_storage_account_variables ? 1 : 0
  repository    = github_repository.alz.name
  variable_name = "USE_STORAGE_ACCOUNT_FOR_PLAN"
  value         = var.use_storage_account_for_plan ? "true" : "false"
}

resource "github_actions_variable" "show_plan_in_pipeline_logs" {
  count         = var.create_storage_account_variables ? 1 : 0
  repository    = github_repository.alz.name
  variable_name = "SHOW_PLAN_IN_PIPELINE_LOGS"
  value         = var.show_plan_in_pipeline_logs ? "true" : "false"
}

resource "github_actions_variable" "plan_storage_container_name" {
  count         = var.create_storage_account_variables && var.use_storage_account_for_plan ? 1 : 0
  repository    = github_repository.alz.name
  variable_name = "PLAN_STORAGE_CONTAINER_NAME"
  value         = var.backend_azure_storage_account_plan_container_name
}

moved {
  from = github_actions_variable.backend_azure_resource_group_name
  to   = github_actions_variable.backend_azure_resource_group_name[0]
}

moved {
  from = github_actions_variable.backend_azure_storage_account_name
  to   = github_actions_variable.backend_azure_storage_account_name[0]
}

moved {
  from = github_actions_variable.backend_azure_storage_account_container_name
  to   = github_actions_variable.backend_azure_storage_account_container_name[0]
}
