resource "azurerm_user_assigned_identity" "alz" {
  for_each            = var.user_assigned_managed_identities
  location            = var.azure_location
  name                = each.value
  resource_group_name = azurerm_resource_group.identity.name
}

resource "azurerm_federated_identity_credential" "alz" {
  for_each            = var.federated_credentials
  name                = each.value.federated_credential_name
  resource_group_name = azurerm_resource_group.identity.name
  audience            = [local.audience]
  issuer              = each.value.federated_credential_issuer
  parent_id           = azurerm_user_assigned_identity.alz[each.value.user_assigned_managed_identity_key].id
  subject             = each.value.federated_credential_subject
}

resource "azurerm_role_definition" "alz_contributor" {
  name        = "Azure Landing Zones Management Group Contributor"
  scope       = data.azurerm_management_group.alz.id
  description = "This is a custom role created by the Azure Landing Zones Accelerator for Writing the Management Group Structure."

  permissions {
    actions     = [
      "Microsoft.Management/managementGroups/delete",
      "Microsoft.Management/managementGroups/read",
      "Microsoft.Management/managementGroups/subscriptions/delete",
      "Microsoft.Management/managementGroups/subscriptions/write",
      "Microsoft.Management/managementGroups/write",
      "Microsoft.Management/managementGroups/subscriptions/read",
      "Microsoft.Authorization/*/read",
      "Microsoft.Resources/deployments/whatIf/action",
      "Microsoft.Resources/deployments/write"
    ]
    not_actions = []
  }
}

resource "azurerm_role_definition" "alz_reader" {
  name        = "Azure Landing Zones Management Group Reader"
  scope       = data.azurerm_management_group.alz.id
  description = "This is a custom role created by the Azure Landing Zones Accelerator for Reading the Management Group Structure."

  permissions {
    actions     = [
      "Microsoft.Management/managementGroups/read",
      "Microsoft.Management/managementGroups/subscriptions/read",
      "Microsoft.Authorization/*/read",
      "Microsoft.Resources/deployments/whatIf/action",
      "Microsoft.Resources/deployments/write"
    ]
    not_actions = []
  }
}

locals {
  subscription_plan_role_assignments = {
    for subscription_id, subscription in data.azurerm_subscription.alz : "plan_${subscription_id}" => {
      scope                = subscription.id
      role_definition_name = "Reader"
      principal_id         = azurerm_user_assigned_identity.alz[local.plan_key].principal_id
    }
  }
  subscription_apply_role_assignments = {
    for subscription_id, subscription in data.azurerm_subscription.alz : "apply_${subscription_id}" => {
      scope                = subscription.id
      role_definition_name = "Owner"
      principal_id         = azurerm_user_assigned_identity.alz[local.apply_key].principal_id
    }
  }
  role_assignments = merge(local.subscription_plan_role_assignments, local.subscription_apply_role_assignments, {
    plan_management_group = {
      scope                = data.azurerm_management_group.alz.id
      role_definition_name = azurerm_role_definition.alz_reader.name
      principal_id         = azurerm_user_assigned_identity.alz[local.plan_key].principal_id
    }
    apply_management_group = {
      scope                = data.azurerm_management_group.alz.id
      role_definition_name = azurerm_role_definition.alz_contributor.name
      principal_id         = azurerm_user_assigned_identity.alz[local.apply_key].principal_id
    }
  })
}

resource "azurerm_role_assignment" "alz" {
  for_each             = local.role_assignments
  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}
