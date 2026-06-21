variable "primary_rg_name" {
  type        = string
  description = "Resource group for the primary SQL server"
}

variable "secondary_rg_name" {
  type        = string
  description = "Resource group for the secondary SQL server"
}

variable "primary_location" {
  type        = string
  description = "Location for the primary SQL server"
}

variable "secondary_location" {
  type        = string
  description = "Location for the secondary SQL server"
}

variable "primary_vnet_id" {
  type        = string
  description = "VNet ID for the primary VNet"
}

variable "secondary_vnet_id" {
  type        = string
  description = "VNet ID for the secondary VNet"
}

variable "primary_pe_subnet_id" {
  type        = string
  description = "Subnet ID for private endpoints in the primary VNet"
}

variable "secondary_pe_subnet_id" {
  type        = string
  description = "Subnet ID for private endpoints in the secondary VNet"
}

variable "db_admin_username" {
  type        = string
  description = "SQL Server administrator username"
  default     = "sqladmin"
}

variable "db_name" {
  type        = string
  description = "The name of the database"
  default     = "strideiqdb"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to database resources"
  default     = {}
}
