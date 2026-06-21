variable "cluster_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "vnet_subnet_id" {
  type = string
}

variable "min_node_count" {
  type = number
}

variable "max_node_count" {
  type = number
}

variable "enable_private_cluster" {
  type = bool
}

variable "enable_zone_redundancy" {
  type = bool
}

variable "enable_workload_identity" {
  type = bool
}

variable "identity_id" {
  type = string
}

variable "log_analytics_workspace_id" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
