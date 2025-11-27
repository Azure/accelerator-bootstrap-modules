# Azure DevOps group membership for agent identity
# The agent identity must be a member of "Project Collection Service Accounts" group
# to access Azure DevOps resources with managed identity authentication

data "azuredevops_group" "project_collection_service_accounts" {
  count = var.use_self_hosted_agents && var.use_container_app_jobs ? 1 : 0
  name  = "Project Collection Service Accounts"
}

resource "azuredevops_group_membership" "agent_identity" {
  count = var.use_self_hosted_agents && var.use_container_app_jobs ? 1 : 0
  group = data.azuredevops_group.project_collection_service_accounts[0].descriptor
  members = [
    module.identities.managed_identity_principal_ids["agent"]
  ]
}
