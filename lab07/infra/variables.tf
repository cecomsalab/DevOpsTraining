variable "resource_group_name" {
  description = "Existing resource group assigned to the learner."
  type        = string
}

variable "prefix" {
  description = "Short lowercase name used in resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,10}$", var.prefix))
    error_message = "The prefix must be 3 to 10 lowercase letters or numbers."
  }
}

variable "address_space" {
  description = "Address space of the virtual network."
  type        = string
  default     = "10.40.0.0/16"
}

variable "subnets" {
  description = "Subnet name to index inside the address space."
  type        = map(number)
  default = {
    web  = 1
    data = 2
  }
}
