variable "location" {
  description = "Azure Region"

  type = string
}

variable "resource_group_name" {
  description = "Resource Group Name"

  type = string
}

variable "tags" {
  description = "Common Resource Tags"

  type = map(string)
}

###############################
# Hub Network
###############################

variable "hub_vnet_name" {
  type = string
}

variable "hub_address_space" {
  type = list(string)
}

variable "hub_subnets" {

  description = "Hub Subnets"

  type = map(object({address_prefixes = list(string)}))
}

###############################
# Spoke Network
###############################

variable "spoke_vnet_name" {
  type = string
}

variable "spoke_address_space" {
  type = list(string)
}

variable "spoke_subnets" {

  description = "Spoke Subnets"

  type = map(object({address_prefixes = list(string)}))
}