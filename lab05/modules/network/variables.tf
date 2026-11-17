variable "name" {
  description = "Name of the virtual network."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group of the virtual network."
  type        = string
}

variable "address_space" {
  description = "Address space of the virtual network."
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnet name to address prefix."
  type        = map(string)
}

variable "tags" {
  description = "Tags applied to the virtual network."
  type        = map(string)
  default     = {}
}
