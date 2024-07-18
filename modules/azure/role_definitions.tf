resource "azurerm_role_definition" "alz" {
  for_each    = var.custom_role_definitions
  name        = each.value.name
  scope       = data.azurerm_management_group.alz.id
  description = each.value.description

  permissions {
    actions     = each.value.permissions.actions
    not_actions = each.value.permissions.not_actions
  }
}
