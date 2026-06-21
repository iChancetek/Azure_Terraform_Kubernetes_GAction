variable "primary_region" {
  type        = string
  description = "The primary Azure region for deployment."
  default     = "eastus"
  validation {
    condition     = contains(["eastus", "centralus", "westus", "westeurope"], var.primary_region)
    error_message = "The primary_region must be a valid Azure region."
  }
}

variable "secondary_region" {
  type        = string
  description = "The secondary Azure region for deployment."
  default     = "centralus"
  validation {
    condition     = contains(["eastus", "centralus", "westus", "westeurope"], var.secondary_region)
    error_message = "The secondary_region must be a valid Azure region."
  }
}

variable "cluster_name" {
  type        = string
  description = "The base name of the AKS cluster."
  default     = "aks-prod"
  validation {
    condition     = length(var.cluster_name) > 3
    error_message = "Cluster name must be longer than 3 characters."
  }
}

variable "cluster_version" {
  type        = string
  description = "The Kubernetes version for the AKS cluster."
  default     = "1.29"
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+", var.cluster_version))
    error_message = "Cluster version must be in the format X.Y."
  }
}

variable "vnet_cidr" {
  type        = string
  description = "The CIDR block for the Virtual Network."
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vnet_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

variable "min_node_count" {
  type        = number
  description = "Minimum number of nodes for the default node pool."
  default     = 2
  validation {
    condition     = var.min_node_count > 0
    error_message = "Minimum node count must be greater than 0."
  }
}

variable "max_node_count" {
  type        = number
  description = "Maximum number of nodes for the default node pool."
  default     = 10
  validation {
    condition     = var.max_node_count >= 2
    error_message = "Maximum node count must be at least 2."
  }
}

variable "enable_failover" {
  type        = bool
  description = "Enable Azure Traffic Manager failover between regions."
  default     = true
  validation {
    condition     = contains([true, false], var.enable_failover)
    error_message = "Must be a boolean value."
  }
}

variable "enable_private_cluster" {
  type        = bool
  description = "Enable private AKS cluster."
  default     = true
  validation {
    condition     = contains([true, false], var.enable_private_cluster)
    error_message = "Must be a boolean value."
  }
}

variable "enable_zone_redundancy" {
  type        = bool
  description = "Enable Availability Zones for AKS."
  default     = true
  validation {
    condition     = contains([true, false], var.enable_zone_redundancy)
    error_message = "Must be a boolean value."
  }
}

variable "enable_workload_identity" {
  type        = bool
  description = "Enable OIDC and Workload Identity."
  default     = true
  validation {
    condition     = contains([true, false], var.enable_workload_identity)
    error_message = "Must be a boolean value."
  }
}

variable "enable_traffic_manager" {
  type        = bool
  description = "Enable Traffic Manager for the application."
  default     = true
  validation {
    condition     = contains([true, false], var.enable_traffic_manager)
    error_message = "Must be a boolean value."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources."
  default = {
    Environment = "production"
    Project     = "StrideIQ"
    ManagedBy   = "Terraform"
  }
  validation {
    condition     = length(var.tags) > 0
    error_message = "At least one tag must be provided."
  }
}
