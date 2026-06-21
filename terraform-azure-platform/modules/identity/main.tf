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

# Public DNS Zone
resource "azurerm_dns_zone" "zone" {
  name                = "strideiq.fit"
  resource_group_name = var.primary_rg_name
  tags                = var.tags
}

# Cert-manager Managed Identities
resource "azurerm_user_assigned_identity" "cert_manager_primary" {
  name                = "mi-cert-manager-primary"
  resource_group_name = var.primary_rg_name
  location            = var.primary_location
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "cert_manager_secondary" {
  name                = "mi-cert-manager-secondary"
  resource_group_name = var.secondary_rg_name
  location            = var.secondary_location
  tags                = var.tags
}

# Role Assignments for DNS-01 verification
resource "azurerm_role_assignment" "dns_contrib_primary" {
  scope                = azurerm_dns_zone.zone.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.cert_manager_primary.principal_id
}

resource "azurerm_role_assignment" "dns_contrib_secondary" {
  scope                = azurerm_dns_zone.zone.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.cert_manager_secondary.principal_id
}
