resource "azurerm_user_assigned_identity" "primary_aks" {
  name                = "mi-aks-primary"
  resource_group_name = var.primary_rg_name
  location            = var.primary_location
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "secondary_aks" {
  name                = "mi-aks-secondary"
  resource_group_name = var.secondary_rg_name
  location            = var.secondary_location
  tags                = var.tags
}
