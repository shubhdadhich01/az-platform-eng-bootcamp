variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "web_vm_name" {
  type = string
}

variable "app_vm_name" {
  type = string
}

variable "web_nic_name" {
  type = string
}

variable "app_nic_name" {
  type = string
}

variable "web_subnet_id" {
  type = string
}

variable "app_subnet_id" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "ssh_key" {
  type = string
}

variable "admin_username" {
    type = string
}

variable "tags" {
  type = map(string)
}

variable "storage_account_name" {}

variable "container_name" {}