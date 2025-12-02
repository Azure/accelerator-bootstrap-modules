data "azurerm_client_config" "current" {}
data "azurerm_subscription" "management" {
  subscription_id = var.subscription_ids["management"]
}
