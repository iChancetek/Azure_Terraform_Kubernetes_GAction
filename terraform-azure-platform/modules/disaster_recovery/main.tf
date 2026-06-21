resource "random_string" "tm_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_traffic_manager_profile" "tm" {
  name                   = "tm-strideiq-${random_string.tm_suffix.result}"
  resource_group_name    = var.resource_group_name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "strideiq-${random_string.tm_suffix.result}"
    ttl           = 60
  }

  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/health"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }

  tags = var.tags
}

resource "azurerm_traffic_manager_external_endpoint" "primary" {
  name       = "primary-endpoint"
  profile_id = azurerm_traffic_manager_profile.tm.id
  priority   = 1
  target     = var.primary_endpoint
}

resource "azurerm_traffic_manager_external_endpoint" "secondary" {
  name       = "secondary-endpoint"
  profile_id = azurerm_traffic_manager_profile.tm.id
  priority   = 2
  target     = var.secondary_endpoint
}
