output "organization_url" {
  description = "The full URL of the Azure DevOps organization, constructed based on whether legacy URL format is used. Format: https://dev.azure.com/<organization> or https://<organization>.visualstudio.com"
  value       = local.organization_url
}

output "subjects" {
  description = "Map of environment keys to their OIDC workload identity federation subject claims. Used for configuring federated credentials in Azure for keyless authentication from Azure DevOps."
  value       = { for key, value in var.environments : key => azuredevops_serviceendpoint_azurerm.alz[key].workload_identity_federation_subject }
}

output "issuers" {
  description = "Map of environment keys to their OIDC workload identity federation issuer URLs. Used for configuring federated credentials in Azure to establish trust with Azure DevOps."
  value       = { for key, value in var.environments : key => azuredevops_serviceendpoint_azurerm.alz[key].workload_identity_federation_issuer }
}

output "agent_pool_name" {
  description = "Name of the Azure DevOps agent pool created for self-hosted agents. Returns null if not using self-hosted agents. Used for registering agents to the correct pool."
  value       = var.use_self_hosted_agents ? azuredevops_agent_pool.alz[0].name : null
}
