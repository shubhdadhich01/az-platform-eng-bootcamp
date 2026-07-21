variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "web_nsg_name" {
  type = string
}

variable "app_nsg_name" {
  type = string
}

variable "web_subnet_id" {
  type =  string
}

variable "app_subnet_id" {
  type = string
}

variable "app_subnet_cidr" {
  type = string
}

variable "web_subnet_cidr" {
  type = string
}

variable "bastion-subnet-cidr" {
  type = string
}

variable "tags" {
  type = map(string)
}