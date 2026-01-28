locals {
  role_assignments = { for key, value in var.role_assignments : key => {
    user_assigned_managed_identity_key = value.user_assigned_managed_identity_key
    built_in_role_definition_name      = value.built_in_role_definition_name
    custom_role_definition_key         = value.custom_role_definition_key
    scope                              = value.scope
    principal_id                       = azurerm_user_assigned_identity.alz[value.user_assigned_managed_identity_key].principal_id
  } }

  subscription_role_assignments = { for assignment in flatten([
    for key, value in local.role_assignments : [
      for subscription_id, subscription in data.azurerm_subscription.alz : {
        key                  = "${value.user_assigned_managed_identity_key}-${coalesce(value.custom_role_definition_key, value.built_in_role_definition_name)}-${subscription_id}"
        scope                = subscription.id
        role_definition_id   = value.built_in_role_definition_name == null ? "${subscription.id}${azurerm_role_definition.alz[value.custom_role_definition_key].role_definition_resource_id}" : null
        role_definition_name = value.built_in_role_definition_name
        principal_id         = value.principal_id
      }
    ] if value.scope == "subscription"
    ]) : assignment.key => {
    scope                = assignment.scope
    role_definition_id   = assignment.role_definition_id
    role_definition_name = assignment.role_definition_name
    principal_id         = assignment.principal_id
  } }

  management_group_role_assignments = {
    for key, value in local.role_assignments : key => {
      scope                = var.intermediate_root_management_group_creation_enabled ? azapi_resource.intermediate_root_management_group[0].id : data.azurerm_management_group.alz.id
      role_definition_id   = value.built_in_role_definition_name == null ? azurerm_role_definition.alz[value.custom_role_definition_key].role_definition_resource_id : null
      role_definition_name = value.built_in_role_definition_name
      principal_id         = value.principal_id
    } if value.scope == "management_group"
  }
  final_role_assignments = merge(local.subscription_role_assignments, local.management_group_role_assignments)
}

resource "azurerm_role_assignment" "alz" {
  for_each             = local.final_role_assignments
  scope                = each.value.scope
  role_definition_id   = each.value.role_definition_id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}

# Bicep needs some permissions at tenant level to deploy management groups and policy in the same deployment
locals {
  tenant_role_assignments = {
    for key, value in azurerm_user_assigned_identity.alz : key => {
      principal_id = value.principal_id
    } if var.tenant_role_assignment_enabled
  }
}

resource "azurerm_role_assignment" "alz_tenant" {
  for_each             = local.tenant_role_assignments
  scope                = "/"
  role_definition_name = var.tenant_role_assignment_role_definition_name
  principal_id         = each.value.principal_id
}
