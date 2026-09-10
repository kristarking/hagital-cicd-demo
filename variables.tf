variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "Name of the Azure resource Group"
  type        = string
  default     = "hagital-rg"
}

variable "location" {
  description = "Azure region to deploy to"
  type        = string
  default     = "East US"
}

variable "vnet_name" {
  description = "Name of the Vnet"
  type        = string
  default     = "hagital-vnet"
}

variable "subnet_net" {
  description = "Name of the subnet"
  type        = string
  default     = "hagital-subnet"
}

variable "subnet_address_prefix" {
  description = "Subnet CIDR"
  type        = list(string)
  default     = ["10.0.0.0/24"]
}

variable "vm_name" {
  description = "Name of the Linux Machine"
  type        = string
  default     = "hagital-vm"
}

variable "ssh_public_path" {
  description = "Admin User key path"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}