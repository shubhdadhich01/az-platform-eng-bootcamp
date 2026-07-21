variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "storage_dns_name" {
  type = string
}

variable "key_vault_dns_name" {
  type = string
}

variable "hub_storage_link" {
  type = string
}

variable "spoke_storage_link" {
  type = string
}

variable "hub_kv_link" {
  type = string
}

variable "spoke_kv_link" {
  type = string
}

variable "hub_vnet_id" {
  type = string
}

variable "spoke_vnet_id" {
  type = string
}