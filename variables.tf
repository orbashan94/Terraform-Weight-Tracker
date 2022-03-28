variable "resource_group_name" {
  type        = string
  description = "RG name in Azure"
}

variable "location" {
  type        = string
  description = "RG location in Azure"
}

variable "vnet_name" {
  type        = string
  description = "VNET name in Azure"
}

variable "vnet_address_space" {
  type        = string
  description = "Virtual network address space(CIDR)"
}

variable "subnet_name_public" {
  type        = string
  description = "Public subnet name in Azure"
}

variable "subnet_name_private" {
  type        = string
  description = "Private subnet name in Azure"
}

variable "app_address_prefix" {
  type        = string
  description = "App address prefixes"
}

variable "db_address_prefix" {
  type        = string
  description = "Db address prefixes"
}

variable "public_ip_name" {
  type        = string
  description = "Public IP name in Azure"
}

variable "nsg_name" {
  type        = string
  description = "NSG name in Azure"
}

variable "asg_name" {
  type        = string
  description = "ASG name"
}

variable "nic_name" {
  type        = string
  description = "NIC name in Azure"
}

variable "nic_app_association_instances" {
  type = number
}

variable "nic_db_association_instances" {
  type = number
}

variable "nic_name_db" {
  type        = string
  description = "NIC name for db in Azure"
}

variable "lb_name" {
  type        = string
  description = "Load balancer name"
}

variable "lb_backend_address_pool_name" {
  type        = string
  description = "Load balancer backend address pool name "
}

variable "avset_name" {
  type        = string
  description = "Availability set name"
}

variable "vm_name" {
  type        = string
  description = "Linux VM name in Azure"
}

variable "vm_size" {
  type        = string
  description = "Virtual machine size configuration"
}

variable "app_instances" {
  type        = number
  description = "Number of web instances"
}

variable "db_instances" {
  type        = number
  description = "Number of db instances"
}

variable "admin_username" {
  type        = string
  description = "Admin username for virtual machines"
}

variable "admin_password" {
  type        = string
  description = "Admin password for virtual machines (Must meet the Azure complexity requirements!)"
}

variable "admin_ip_address" {
  type        = string
  description = "Admin IP address"
}

variable "admin_db_username" {
  type        = string
  description = "Username for PostgreSQL (service)"
}

variable "admin_db_password" {
  type        = string
  description = "Password for PostgreSQL (service)"
}
