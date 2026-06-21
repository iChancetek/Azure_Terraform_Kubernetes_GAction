resource "azurerm_kubernetes_cluster" "aks" {
  name                                = var.cluster_name
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  dns_prefix                          = var.cluster_name
  kubernetes_version                  = var.kubernetes_version
  private_cluster_enabled             = var.enable_private_cluster
  private_cluster_public_fqdn_enabled = var.enable_private_cluster
  oidc_issuer_enabled                 = var.enable_workload_identity
  workload_identity_enabled           = var.enable_workload_identity

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  default_node_pool {
    name                = "systempool"
    vm_size             = "Standard_B2s"
    vnet_subnet_id      = var.vnet_subnet_id
    zones               = var.enable_zone_redundancy ? ["1", "2", "3"] : []
    enable_auto_scaling = true
    min_count           = var.min_node_count
    max_count           = var.max_node_count
    os_disk_size_gb     = 64
    type                = "VirtualMachineScaleSets"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure"
    load_balancer_sku   = "standard"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  azure_policy_enabled = true

  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id != null ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "general" {
  name                  = "generalpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_D2s_v5"
  vnet_subnet_id        = var.vnet_subnet_id
  zones                 = var.enable_zone_redundancy ? ["1", "2", "3"] : []
  enable_auto_scaling   = true
  min_count             = var.min_node_count
  max_count             = var.max_node_count
  os_disk_size_gb       = 64
  tags                  = var.tags
}
