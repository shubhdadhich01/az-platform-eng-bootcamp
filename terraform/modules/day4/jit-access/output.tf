output "jit_policy" {
  value = var.enabled ? azapi_resource.jit_policy[0].id : null
}