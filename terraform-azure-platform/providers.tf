provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "azuread" {}

provider "helm" {
  alias = "primary"
  kubernetes {
    host                   = module.aks_primary.cluster_endpoint
    client_certificate     = base64decode(module.aks_primary.client_certificate)
    client_key             = base64decode(module.aks_primary.client_key)
    cluster_ca_certificate = base64decode(module.aks_primary.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  alias                  = "primary"
  host                   = module.aks_primary.cluster_endpoint
  client_certificate     = base64decode(module.aks_primary.client_certificate)
  client_key             = base64decode(module.aks_primary.client_key)
  cluster_ca_certificate = base64decode(module.aks_primary.cluster_ca_certificate)
}

provider "helm" {
  alias = "secondary"
  kubernetes {
    host                   = module.aks_secondary.cluster_endpoint
    client_certificate     = base64decode(module.aks_secondary.client_certificate)
    client_key             = base64decode(module.aks_secondary.client_key)
    cluster_ca_certificate = base64decode(module.aks_secondary.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  alias                  = "secondary"
  host                   = module.aks_secondary.cluster_endpoint
  client_certificate     = base64decode(module.aks_secondary.client_certificate)
  client_key             = base64decode(module.aks_secondary.client_key)
  cluster_ca_certificate = base64decode(module.aks_secondary.cluster_ca_certificate)
}
