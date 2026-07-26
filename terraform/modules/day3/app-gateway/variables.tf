variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "spoke_vnet_name" {
  type = string
}

variable "appgw_subnet_name" {
  type = string
}

variable "appgw_subnet_cidr" {
  type = string
}

variable "appgw_nsg_name" {
  type = string
}

variable "public_ip_name" {
  type = string
}

variable "identity_name" {
  type = string
}

variable "cert_vault_name" {
  type = string
}

variable "waf_policy_name" {
  type = string
}

variable "appgw_name" {
  type = string
}

variable "health_probe_path" {
  type = string
  default = "/healthz"
}

variable "tags" {
  type = map(string)
}

variable "key_vault_certificate_secret_id" {
  type = string
}