variable "resource_group_name" {
  description = "Existing resource group assigned to the learner, for example rg-jdoe-usa."
  type        = string
}

variable "prefix" {
  description = "Short lowercase name used in every resource name, for example the student name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,10}$", var.prefix))
    error_message = "The prefix must be 3 to 10 lowercase letters or numbers."
  }
}

variable "address_space" {
  description = "Address space of the virtual network."
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default = {
    environment = "lab"
  }
}
