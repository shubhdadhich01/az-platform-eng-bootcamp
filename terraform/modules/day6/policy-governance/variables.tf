variable "initiative_name" {
  type = string
}

variable "assignment_name" {
  type = string
}

variable "resource_group_id" {
  type = string
}

variable "allowed_vm_skus" {
  type = list(string)
  default = [ "Standard_B1s", "Standard_B2s" ]
}

variable "allowed_locations" {
  type = list(string)
  default = [ "centralindia" ]
}