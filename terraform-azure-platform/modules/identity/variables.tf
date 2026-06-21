variable "primary_rg_name" {
  type        = string
  description = "The name of the primary resource group"
}

variable "secondary_rg_name" {
  type        = string
  description = "The name of the secondary resource group"
}

variable "primary_location" {
  type        = string
  description = "The primary Azure region"
}

variable "secondary_location" {
  type        = string
  description = "The secondary Azure region"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
