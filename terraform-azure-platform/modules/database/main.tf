resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_string" "sql_server_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_mssql_server" "primary" {
  name                         = "sql-primary-${random_string.sql_server_suffix.result}"
  resource_group_name          = var.primary_rg_name
  location                     = var.primary_location
  version                      = "12.0"
  administrator_login          = var.db_admin_username
  administrator_login_password = random_password.db_password.result
  minimum_tls_version          = "1.2"
  tags                         = var.tags
}

resource "azurerm_mssql_server" "secondary" {
  name                         = "sql-secondary-${random_string.sql_server_suffix.result}"
  resource_group_name          = var.secondary_rg_name
  location                     = var.secondary_location
  version                      = "12.0"
  administrator_login          = var.db_admin_username
  administrator_login_password = random_password.db_password.result
  minimum_tls_version          = "1.2"
  tags                         = var.tags
}

resource "azurerm_mssql_database" "db" {
  name         = var.db_name
  server_id    = azurerm_mssql_server.primary.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "BasePrice"
  max_size_gb  = 5
  sku_name     = "S0"
  tags         = var.tags
}

resource "azurerm_mssql_failover_group" "fog" {
  name      = "sql-fog-${random_string.sql_server_suffix.result}"
  server_id = azurerm_mssql_server.primary.id
  databases = [
    azurerm_mssql_database.db.id
  ]

  partner_server {
    id = azurerm_mssql_server.secondary.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }

  tags = var.tags
}

# Private DNS Zone for SQL Server
resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.primary_rg_name
  tags                = var.tags
}

# Link private DNS zone to Primary VNet
resource "azurerm_private_dns_zone_virtual_network_link" "primary" {
  name                  = "link-to-primary-vnet"
  resource_group_name   = var.primary_rg_name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = var.primary_vnet_id
  registration_enabled  = false
  tags                  = var.tags
}

# Link private DNS zone to Secondary VNet
resource "azurerm_private_dns_zone_virtual_network_link" "secondary" {
  name                  = "link-to-secondary-vnet"
  resource_group_name   = var.primary_rg_name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = var.secondary_vnet_id
  registration_enabled  = false
  tags                  = var.tags
}

# Private Endpoint for Primary SQL Server
resource "azurerm_private_endpoint" "primary" {
  name                = "pe-sql-primary"
  location            = var.primary_location
  resource_group_name = var.primary_rg_name
  subnet_id           = var.primary_pe_subnet_id

  private_service_connection {
    name                           = "psc-sql-primary"
    private_connection_resource_id = azurerm_mssql_server.primary.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-group-primary"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql_dns.id]
  }

  tags = var.tags
}

# Private Endpoint for Secondary SQL Server
resource "azurerm_private_endpoint" "secondary" {
  name                = "pe-sql-secondary"
  location            = var.secondary_location
  resource_group_name = var.secondary_rg_name
  subnet_id           = var.secondary_pe_subnet_id

  private_service_connection {
    name                           = "psc-sql-secondary"
    private_connection_resource_id = azurerm_mssql_server.secondary.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-group-secondary"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql_dns.id]
  }

  tags = var.tags
}
