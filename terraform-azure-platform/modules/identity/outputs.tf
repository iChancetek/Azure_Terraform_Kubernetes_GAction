output "primary_mi_id" {
  value = azurerm_user_assigned_identity.primary_aks.id
}

output "secondary_mi_id" {
  value = azurerm_user_assigned_identity.secondary_aks.id
}

output "primary_mi_principal_id" {
  value = azurerm_user_assigned_identity.primary_aks.principal_id
}

output "secondary_mi_principal_id" {
  value = azurerm_user_assigned_identity.secondary_aks.principal_id
}

output "managed_identity_ids" {
  value = [
    azurerm_user_assigned_identity.primary_aks.id,
    azurerm_user_assigned_identity.secondary_aks.id
  ]
}

output "dns_zone_id" {
  value = azurerm_dns_zone.zone.id
}

output "dns_zone_name" {
  value = azurerm_dns_zone.zone.name
}

output "cert_manager_primary_mi_id" {
  value = azurerm_user_assigned_identity.cert_manager_primary.id
}

output "cert_manager_secondary_mi_id" {
  value = azurerm_user_assigned_identity.cert_manager_secondary.id
}

output "cert_manager_primary_mi_client_id" {
  value = azurerm_user_assigned_identity.cert_manager_primary.client_id
}

output "cert_manager_secondary_mi_client_id" {
  value = azurerm_user_assigned_identity.cert_manager_secondary.client_id
}
