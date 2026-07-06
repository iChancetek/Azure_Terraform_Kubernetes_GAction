terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {
    # Configuration passed via -backend-config flags in CI/CD workflows
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.2"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.48"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

}
