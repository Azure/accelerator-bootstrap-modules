resource "azapi_resource" "subscription_placement" {
  for_each = var.move_subscriptions_to_target_management_group ? { for subscription_id in var.target_subscriptions : subscription_id => subscription_id } : {}

  name                   = each.value
  parent_id              = var.intermediate_root_management_group_creation_enabled ? azapi_resource.intermediate_root_management_group[0].id : data.azurerm_management_group.alz.id
  type                   = "Microsoft.Management/managementGroups/subscriptions@2023-04-01"
  response_export_values = []
  retry = {
    error_message_regex = [
      "AuthorizationFailed", # Avoids a eventual consistency issue where a recently created management group is not yet available for a GET operation.
    ]
  }

  timeouts {
    create = "60m"
    delete = "5m"
    read   = "60m"
    update = "5m"
  }
}
