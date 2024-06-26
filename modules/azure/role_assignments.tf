locals {
  subscription_role_assignments = { for assignment in flatten([
    for key, value in var.role_assignments : [
      for subscription_id, subscription in data.azurerm_subscription.alz : {
        key                = "${value.user_assigned_managed_identity_key}-${value.custom_role_definition_key}-${subscription_id}"
        scope              = subscription.id
        role_definition_id = "${subscription.id}${azurerm_role_definition.alz[value.custom_role_definition_key].role_definition_resource_id}"
        principal_id       = azurerm_user_assigned_identity.alz[value.user_assigned_managed_identity_key].principal_id
      }
    ] if value.scope == "subscription"
    ]) : assignment.key => {
    scope              = assignment.scope
    role_definition_id = assignment.role_definition_id
    principal_id       = assignment.principal_id
  } }

  management_group_role_assignments = {
    for key, value in var.role_assignments : key => {
      scope              = data.azurerm_management_group.alz.id
      role_definition_id = azurerm_role_definition.alz[value.custom_role_definition_key].role_definition_resource_id
      principal_id       = azurerm_user_assigned_identity.alz[value.user_assigned_managed_identity_key].principal_id
    } if value.scope == "management_group"
  }
  role_assignments = merge(local.subscription_role_assignments, local.management_group_role_assignments)
}

resource "azurerm_role_assignment" "alz" {
  for_each           = local.role_assignments
  scope              = each.value.scope
  role_definition_id = each.value.role_definition_id
  principal_id       = each.value.principal_id
}
