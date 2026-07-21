variable "resource_group_name" {
    type = string
}

variable "location" {
  type = string
}

variable "route_table_name" {
  type = string
}

variable "firewall_private_ip" {
  type = string
}

variable "spoke_subnet_ids" {
  type = map(string)
}

variable "tags" {}