variable "location" {
  description = "Primary Azure Region"

  type    = string
  default = "Central India"
}

variable "environment" {
  description = "Deployment Environment"

  type    = string
  default = "prod"
}

variable "project_name" {
  description = "Project Name"

  type    = string
  default = "northwind"
}

variable "owner" {
  description = "Platform Owner"

  type    = string
  default = "Platform-Team"
}

variable "admin_username" {
  description = "Administrator username for Linux VMs"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Local path to the SSH public key"
  type        = string
}

variable "log_retention_days" {
  type = number
}

variable "secret_value" {
  type = string
  sensitive = true
}

variable "storage_dns_name" {
  type = string
}

variable "key_vault_dns_name" {
  type = string
}