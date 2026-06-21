data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "primary" {
  name     = "${local.name_prefix}-primary-rg"
  location = var.primary_region
  tags     = var.tags
}

resource "azurerm_resource_group" "secondary" {
  name     = "${local.name_prefix}-secondary-rg"
  location = var.secondary_region
  tags     = var.tags
}

resource "random_string" "acr_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_container_registry" "acr" {
  name                = "acrstrideiq${random_string.acr_suffix.result}"
  resource_group_name = azurerm_resource_group.primary.name
  location            = var.primary_region
  sku                 = "Premium"
  tags                = var.tags

  georeplications {
    location                = var.secondary_region
    zone_redundancy_enabled = false
    tags                    = var.tags
  }
}

module "networking_primary" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.primary.name
  location            = var.primary_region
  vnet_cidr           = var.vnet_cidr
  tags                = var.tags
}

module "networking_secondary" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.secondary.name
  location            = var.secondary_region
  vnet_cidr           = var.vnet_cidr
  tags                = var.tags
}

module "identity" {
  source             = "./modules/identity"
  primary_rg_name    = azurerm_resource_group.primary.name
  secondary_rg_name  = azurerm_resource_group.secondary.name
  primary_location   = var.primary_region
  secondary_location = var.secondary_region
  tags               = var.tags
}

module "security" {
  source              = "./modules/security"
  resource_group_name = azurerm_resource_group.primary.name
  location            = var.primary_region
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = var.tags
}

module "aks_primary" {
  source                     = "./modules/aks"
  cluster_name               = "${var.cluster_name}-primary"
  location                   = var.primary_region
  resource_group_name        = azurerm_resource_group.primary.name
  kubernetes_version         = var.cluster_version
  vnet_subnet_id             = module.networking_primary.aks_subnet_id
  min_node_count             = var.min_node_count
  max_node_count             = var.max_node_count
  enable_private_cluster     = var.enable_private_cluster
  enable_zone_redundancy     = var.enable_zone_redundancy
  enable_workload_identity   = var.enable_workload_identity
  identity_id                = module.identity.primary_mi_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = var.tags
}

module "aks_secondary" {
  source                     = "./modules/aks"
  cluster_name               = "${var.cluster_name}-secondary"
  location                   = var.secondary_region
  resource_group_name        = azurerm_resource_group.secondary.name
  kubernetes_version         = var.cluster_version
  vnet_subnet_id             = module.networking_secondary.aks_subnet_id
  min_node_count             = var.min_node_count
  max_node_count             = var.max_node_count
  enable_private_cluster     = var.enable_private_cluster
  enable_zone_redundancy     = var.enable_zone_redundancy
  enable_workload_identity   = var.enable_workload_identity
  identity_id                = module.identity.secondary_mi_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = var.tags
}

module "disaster_recovery" {
  source              = "./modules/disaster_recovery"
  count               = var.enable_failover ? 1 : 0
  resource_group_name = azurerm_resource_group.primary.name
  location            = var.primary_region
  primary_endpoint    = module.aks_primary.cluster_fqdn
  secondary_endpoint  = module.aks_secondary.cluster_fqdn
  tags                = var.tags
}

module "addons_primary" {
  source = "./modules/addons"
  providers = {
    helm       = helm.primary
    kubernetes = kubernetes.primary
  }
  cluster_name = module.aks_primary.cluster_name
}

module "addons_secondary" {
  source = "./modules/addons"
  providers = {
    helm       = helm.secondary
    kubernetes = kubernetes.secondary
  }
  cluster_name = module.aks_secondary.cluster_name
}

module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = azurerm_resource_group.primary.name
  location            = var.primary_region
  tags                = var.tags
}

module "cost_optimization" {
  source              = "./modules/cost_optimization"
  resource_group_name = azurerm_resource_group.primary.name
  tags                = var.tags
}

module "database" {
  source                  = "./modules/database"
  primary_rg_name         = azurerm_resource_group.primary.name
  secondary_rg_name       = azurerm_resource_group.secondary.name
  primary_location        = var.primary_region
  secondary_location      = var.secondary_region
  primary_vnet_id         = module.networking_primary.vnet_id
  secondary_vnet_id       = module.networking_secondary.vnet_id
  primary_pe_subnet_id    = module.networking_primary.subnet_ids.private_endpoint
  secondary_pe_subnet_id  = module.networking_secondary.subnet_ids.private_endpoint
  tags                    = var.tags
}

module "compute" {
  source              = "./modules/compute"
  resource_group_name = azurerm_resource_group.primary.name
  location            = var.primary_region
  bastion_subnet_id   = module.networking_primary.subnet_ids.bastion
  jumpbox_subnet_id   = module.networking_primary.subnet_ids.private_endpoint
  tags                = var.tags
}

# Workload Identity Federated Credentials for cert-manager
resource "azurerm_federated_identity_credential" "cert_manager_primary" {
  name                = "cert-manager-fed-cred-primary"
  resource_group_name = azurerm_resource_group.primary.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.aks_primary.oidc_issuer_url
  parent_id           = module.identity.cert_manager_primary_mi_id
  subject             = "system:serviceaccount:cert-manager:cert-manager"
}

resource "azurerm_federated_identity_credential" "cert_manager_secondary" {
  name                = "cert-manager-fed-cred-secondary"
  resource_group_name = azurerm_resource_group.secondary.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.aks_secondary.oidc_issuer_url
  parent_id           = module.identity.cert_manager_secondary_mi_id
  subject             = "system:serviceaccount:cert-manager:cert-manager"
}
