variable "resource_group_name" {
   type = string 
}

variable "location" {
  type = string
}

variable "ansible_vm_name" {
  type = string
}

variable "ansible_nic_name" {
  type = string
}

variable "ansible_nsg_name" {
  type = string
}

variable "ansible_subnet_id" {
  type = string
}

variable "bastion_subnet_cidr" {
  type = string
}

variable "route_table_id" {
  type = string
}

variable "ansible_vm_size" {
  type = string
}

variable "ansible_admin_username" {
  type = string
}

variable "ansible_ssh_key" {
  type = string
  sensitive = true
}

variable "tags" {
  type = map(string)
}

variable "web_vm_name" {
  type = string
}

variable "web_private_ip" {
  type = string
}

variable "app_vm_name" {
  type = string
}

variable "app_private_ip" {
  type = string
}