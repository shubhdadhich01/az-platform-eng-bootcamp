variable "enabled" {
  description = "Master switch for the JIT module (requires Defender for Servers)"  
  type    = bool
  default = false
}

variable "enable_defender_plan" {
  description = "Also enable the paid Defender for Servers P2 plan on the subscription"
  type        = bool
  default     = false
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_ids" {
  type = list(string)
}

variable "jit_policy_name" {
  type = string
}
