resource "azuredevops_agent_pool" "alz" {
  count          = var.use_self_hosted_agents ? 1 : 0
  name           = var.agent_pool_name
  auto_provision = false
  auto_update    = true
}

resource "azuredevops_agent_queue" "alz" {
  count         = var.use_self_hosted_agents ? 1 : 0
  project_id    = local.project_id
  agent_pool_id = azuredevops_agent_pool.alz[0].id
}
