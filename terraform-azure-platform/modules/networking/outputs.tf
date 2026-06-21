output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks.id
}

output "subnet_ids" {
  value = {
    aks              = azurerm_subnet.aks.id
    private_endpoint = azurerm_subnet.private_endpoint.id
    ingress          = azurerm_subnet.ingress.id
    bastion          = azurerm_subnet.bastion.id
  }
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}
