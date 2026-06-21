variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "primary_endpoint" {
  type = string
}

variable "secondary_endpoint" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
