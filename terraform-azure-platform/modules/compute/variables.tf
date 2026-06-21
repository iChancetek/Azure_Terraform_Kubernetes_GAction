variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region"
}

variable "bastion_subnet_id" {
  type        = string
  description = "The ID of the AzureBastionSubnet subnet"
}

variable "jumpbox_subnet_id" {
  type        = string
  description = "The ID of the subnet for the Jumpbox VM"
}

variable "admin_username" {
  type        = string
  description = "The administrator username for the Jumpbox VM"
  default     = "strideadmin"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to compute resources"
  default     = {}
}
