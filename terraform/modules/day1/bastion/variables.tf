variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "bastion_name" {
  type = string
}

variable "bastion_public_ip_name" {
  type = string
}

variable "bastion_subnet_id" {
  type = string
}

variable "tags" {
  type = map(string)
}