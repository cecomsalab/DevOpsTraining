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
  default     = "10.30.0.0/16"
}

variable "subnets" {
  description = "Subnets to create. The key is the subnet name, the value its index inside the address space."
  type        = map(number)
  default = {
    web  = 1
    data = 2
  }
}

variable "allowed_ssh_cidr" {
  description = "Public IP range allowed to connect with SSH, for example 203.0.113.10/32."
  type        = string
}

variable "vm_size" {
  description = "Size of the Linux virtual machine."
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Administrator user name of the virtual machine."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file."
  type        = string
  default     = "~/.ssh/lab05_ed25519.pub"
}
