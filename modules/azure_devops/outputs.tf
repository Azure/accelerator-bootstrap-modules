output "organization_url" {
  value = local.organization_url
}

output "subjects" {
  value = { for key, value in var.environments : key => azuredevops_serviceendpoint_azurerm.alz[key].workload_identity_federation_subject }
}

output "issuers" {
  value = { for key, value in var.environments : key => azuredevops_serviceendpoint_azurerm.alz[key].workload_identity_federation_issuer }
}

output "agent_pool_name" {
  value = var.use_self_hosted_agents ? azuredevops_agent_pool.alz[0].name : null
}
