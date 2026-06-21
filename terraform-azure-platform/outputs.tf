output "primary_aks_name" {
  value = module.aks_primary.cluster_name
}

output "primary_aks_id" {
  value = module.aks_primary.cluster_id
}

output "primary_aks_fqdn" {
  value = module.aks_primary.cluster_fqdn
}

output "secondary_aks_name" {
  value = module.aks_secondary.cluster_name
}

output "secondary_aks_id" {
  value = module.aks_secondary.cluster_id
}

output "secondary_aks_fqdn" {
  value = module.aks_secondary.cluster_fqdn
}

output "primary_resource_group" {
  value = azurerm_resource_group.primary.name
}

output "secondary_resource_group" {
  value = azurerm_resource_group.secondary.name
}

output "primary_vnet_id" {
  value = module.networking_primary.vnet_id
}

output "primary_subnet_ids" {
  value = module.networking_primary.subnet_ids
}

output "managed_identity_ids" {
  value = module.identity.managed_identity_ids
}

output "key_vault_uri" {
  value = module.security.key_vault_uri
}

output "traffic_manager_endpoint" {
  value = var.enable_failover ? module.disaster_recovery[0].traffic_manager_fqdn : null
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "primary_region" {
  value = var.primary_region
}

output "secondary_region" {
  value = var.secondary_region
}
