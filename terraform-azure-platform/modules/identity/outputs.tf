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
