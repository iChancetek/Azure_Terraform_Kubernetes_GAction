output "primary_server_id" {
  value = azurerm_mssql_server.primary.id
}

output "secondary_server_id" {
  value = azurerm_mssql_server.secondary.id
}

output "primary_server_name" {
  value = azurerm_mssql_server.primary.name
}

output "secondary_server_name" {
  value = azurerm_mssql_server.secondary.name
}

output "database_name" {
  value = azurerm_mssql_database.db.name
}

output "failover_group_name" {
  value = azurerm_mssql_failover_group.fog.name
}

output "failover_group_endpoint" {
  value       = "${azurerm_mssql_failover_group.fog.name}.database.windows.net"
  description = "The connection endpoint for application database connections"
}

output "admin_username" {
  value = var.db_admin_username
}

output "admin_password" {
  value     = random_password.db_password.result
  sensitive = true
}
