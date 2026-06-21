output "bastion_id" {
  value = azurerm_bastion_host.bastion.id
}

output "jumpbox_private_ip" {
  value = azurerm_linux_virtual_machine.jumpbox.private_ip_address
}

output "admin_username" {
  value = var.admin_username
}

output "admin_password" {
  value     = random_password.vm_password.result
  sensitive = true
}
