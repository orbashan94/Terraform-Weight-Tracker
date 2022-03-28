variable "resource_group_name" {
  type        = string
  description = "RG name in Azure"
}

variable "location" {
  type        = string
  description = "RG location in Azure"
}

variable "vm_name" {
  type        = string
  description = "VM name in Azure"
}

variable "vm_size" {
  type        = string
  description = "VM size in Azure"
}

variable "vm_type" {
  type = string
}

variable "vnet_name" {
  type        = string
  description = "VNET name in Azure"
}

variable "admin_username" {
  type        = string
  description = "Admin username for accessing vm"
}

variable "admin_password" {
  type        = string
  description = "Admin password for accessing vm"
}

variable "index" {
  type = number
}

variable "avset_id" {
  type = string
}

variable "snet_id" {
  type = string
}
