# resource "azurerm_management_lock" "rg_lock" {
#   name       = "rg-level-lock"
#   scope      = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}"
#   lock_level = "CanNotDelete"
#   notes      = "Prevent accidental deletion of production resource group."
# }

data "azurerm_subscription" "current" {}
