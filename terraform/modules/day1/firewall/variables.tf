variable "resource_group_name" {
  type = string
}

variable "location" {
    type = string
}

variable "tags" {}

variable "firewall_name" {
    type = string
}

variable "firewall_policy_name" {
    type = string
}

variable "hub_vnet_name" {
  type = string
}

variable "firewall_subnet_id" {
  type = string
}

variable "public_ip_name" {
    type = string
}