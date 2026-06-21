resource "random_string" "kv_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_key_vault" "kv" {
  name                      = "kv-strideiq-${random_string.kv_suffix.result}"
  location                  = var.location
  resource_group_name       = var.resource_group_name
  tenant_id                 = var.tenant_id
  sku_name                  = "standard"
  purge_protection_enabled  = false
  enable_rbac_authorization = true

  tags = var.tags
}

resource "azurerm_security_center_subscription_pricing" "mdc" {
  tier          = "Free"
  resource_type = "VirtualMachines"
}

resource "azurerm_resource_group_policy_assignment" "aks_policy" {
  name                 = "aks-baseline"
  resource_group_id    = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/a8640138-9b0a-4a28-b8cb-1666c838647d"
  description          = "Assigns the Kubernetes baseline policy set to the resource group."
}

data "azurerm_subscription" "current" {}
