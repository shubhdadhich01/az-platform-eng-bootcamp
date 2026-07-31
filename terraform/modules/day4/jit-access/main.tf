#########################################################
# Just-In-Time VM Access Policy (via azapi)
#
# Requires Microsoft Defender for Servers Plan 2 enabled on the subscription. Because that is a 
# subscription-wide paid plan, this whole module is OPT-IN (var.enabled).
# Native azurerm has no JIT resource, so azapi is used --
# this is the real architect-level "provider gap" workaround
# the Day 4 scenario teaches.
#########################################################

resource "azurerm_security_center_subscription_pricing" "servers" {
  count         = var.enabled && var.enable_defender_plan ? 1 : 0
  tier          = "Standard"
  resource_type = "VirtualMachines"
  subplan       = "P2"
}

data "azurerm_client_config" "current" {}

locals {
    subscription_id = data.azurerm_client_config.current.subscription_id
}

resource "azapi_resource" "jit_policy" {
  count     = var.enabled ? 1 : 0
  name      = var.jit_policy_name
  type      = "Microsoft.Security/locations/jitNetworkAccessPolicies@2020-01-01"
  parent_id = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Security/locations/${var.location}"

  body = {
    kind = "Basic"
    properties = {
        virtualMachines = [
            for vm_id in var.vm_ids : {
                id = vm_id
                ports = [
                    {
                        number = 22
                        protocol = "TCP"
                        allowedSourceAddressPrefix = "*"
                        maxRequestAccessDuration = "PT30M"
                    }
                ]
            }
        ]
    }
  }
}