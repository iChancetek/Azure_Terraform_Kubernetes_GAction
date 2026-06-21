terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {
    # Backend configuration should be provided via init arguments or backend.tfvars
    # Example: terraform init -backend-config="resource_group_name=rg-terraform-state" ...
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
      version = "~> 2.30"
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
