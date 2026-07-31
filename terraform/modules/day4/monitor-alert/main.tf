#########################################################
# Action Group (email notification target)
#########################################################

resource "azurerm_monitor_action_group" "security_ops" {
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = var.action_group_short_name
  tags                = var.tags

  email_receiver {
    name = "secops"
    email_address = var.notification_email
    }
}

#########################################################
# Activity Log Alert on JIT Access Requests
#########################################################

data "azurerm_client_config" "current" {}

locals {
    subscription_id = data.azurerm_client_config.current.subscription_id
}

resource "azurerm_monitor_activity_log_alert" "jit_request" {
  name                = var.alert_name
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = ["/subscriptions/${local.subscription_id}"]
  description         = "Fires when a Just-In-Time VM access request is initiated"
  tags                = var.tags

  criteria {
    category       = "Security"
    operation_name = "Microsoft.Security/locations/jitNetworkAccessPolicies/initiate/action"
  }

  action {
    action_group_id = azurerm_monitor_action_group.security_ops.id
  }
}