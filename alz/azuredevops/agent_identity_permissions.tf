# Azure DevOps Service Principal Entitlement for Agent Identity
# Required for UAMI authentication to work with Azure DevOps
# Pattern from: https://github.com/Azure/terraform-azurerm-avm-ptn-cicd-agents-and-runners/blob/main/examples/azure_devops_container_app_uami/main.tf

data "azuredevops_group" "project_collection_service_accounts" {
  count = var.use_self_hosted_agents && var.use_container_app_jobs ? 1 : 0
  name  = "Project Collection Service Accounts"
}

# Wait for UAMI propagation in Azure AD
resource "time_sleep" "agent_identity_propagation" {
  count           = var.use_self_hosted_agents && var.use_container_app_jobs ? 1 : 0
  create_duration = "30s"

  depends_on = [module.identities]
}

# Create service principal entitlement for the agent UAMI
resource "azuredevops_service_principal_entitlement" "agent_identity" {
  count                = var.use_self_hosted_agents && var.use_container_app_jobs ? 1 : 0
  account_license_type = "express" # Basic license for service principals
  origin               = "aad"     # Azure Active Directory
  origin_id            = module.identities.managed_identity_principal_ids["agent"]

  depends_on = [time_sleep.agent_identity_propagation]
}

# Add agent identity service principal to Project Collection Service Accounts group
resource "azuredevops_group_membership" "agent_identity" {
  count   = var.use_self_hosted_agents && var.use_container_app_jobs ? 1 : 0
  group   = data.azuredevops_group.project_collection_service_accounts[0].descriptor
  members = [azuredevops_service_principal_entitlement.agent_identity[0].descriptor]
  mode    = "add"

  depends_on = [
    azuredevops_service_principal_entitlement.agent_identity,
    data.azuredevops_group.project_collection_service_accounts
  ]
}
