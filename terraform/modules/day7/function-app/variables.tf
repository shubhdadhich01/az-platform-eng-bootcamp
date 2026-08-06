variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "spoke_vnet_name" {
  type = string
}

variable "func_subnet_name" {
  type = string
}

variable "func_subnet_cidr" {
  type = string
}

variable "func_storage_name" {
  type = string
}

variable "plan_name" {
  type = string
}

variable "app_insights_name" {
  type = string
}

variable "function_app_name" {
  type = string
}

variable "log_analytics_id" {
  type = string
}

variable "data_storage_account_name" {
  type = string
}

variable "data_container_name" {
  type = string
}

variable "data_container_id" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "storage_container_id" {
  type = string
}

variable "ansible_vm_principle_id" {
  type = string
}

variable "tags" {
  type = map(string)
}