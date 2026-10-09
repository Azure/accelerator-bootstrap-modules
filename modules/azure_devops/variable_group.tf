resource "azuredevops_variable_group" "alz" {
  count        = var.create_variable_group ? 1 : 0
  project_id   = local.project_id
  name         = var.variable_group_name
  description  = var.variable_group_name
  allow_access = true

  variable {
    name  = "BACKEND_AZURE_RESOURCE_GROUP_NAME"
    value = var.backend_azure_resource_group_name
  }

  variable {
    name  = "BACKEND_AZURE_STORAGE_ACCOUNT_NAME"
    value = var.backend_azure_storage_account_name
  }

  variable {
    name  = "BACKEND_AZURE_STORAGE_ACCOUNT_CONTAINER_NAME"
    value = var.backend_azure_storage_account_container_name
  }

  variable {
    name  = "USE_STORAGE_ACCOUNT_FOR_PLAN"
    value = var.use_storage_account_for_plan ? "true" : "false"
  }

  variable {
    name  = "SHOW_PLAN_IN_PIPELINE_LOGS"
    value = var.show_plan_in_pipeline_logs ? "true" : "false"
  }

  dynamic "variable" {
    for_each = var.use_storage_account_for_plan && var.backend_azure_storage_account_plan_container_name != null ? [1] : []

    content {
      name  = "PLAN_STORAGE_CONTAINER_NAME"
      value = var.backend_azure_storage_account_plan_container_name
    }
  }
}

moved {
  from = azuredevops_variable_group.example
  to   = azuredevops_variable_group.alz[0]
}
