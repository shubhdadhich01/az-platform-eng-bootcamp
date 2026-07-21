variable "key_vault_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "secret_name" {
  type = string
}

variable "secret_value" {
  type = string
  sensitive = true
}

variable "tags" {
  type = map(string)
}