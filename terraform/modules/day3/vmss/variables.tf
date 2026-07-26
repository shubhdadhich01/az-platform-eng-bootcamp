variable "web_vmss_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vmss_size" {
  type = string
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "min_instances" {
  type    = number
  default = 1
}

variable "max_instances" {
  type    = number
  default = 2
}

variable "admin_username" {
  type = string
}

variable "ssh_key" {
  type = string
}

variable "web_subnet_id" {
  type = string
}

variable "backend_pool_ids" {
  description = "Application Gateway backend address pool IDs to attach VMSS instances to"
  type        = list(string)
}

variable "tags" {
  type = map(string)
}