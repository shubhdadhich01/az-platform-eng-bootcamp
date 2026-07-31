variable "resource_group_name" {
  type = string
}

variable "action_group_name" {
  type = string
}

variable "action_group_short_name" {
  type = string
  default = "secops"
}

variable "notification_email" {
  type = string
}

variable "alert_name" {
  type = string
}

variable "tags" {
  type = map(string)
}