variable "storage_account_name" {
  type = string
}

variable "container_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "storage_identity_id" {
  type = string
}