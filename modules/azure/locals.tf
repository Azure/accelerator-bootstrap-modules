locals {
  audience = "api://AzureADTokenExchange"
}

locals {
  subscription_ids = { for subscription_id in distinct(var.target_subscriptions) : subscription_id => subscription_id }
}
