#########################################################
# Policy Definitions (custom) — the initiative building blocks
#########################################################

# 1) Deny resources missing the CostCenter tag

resource "azurerm_policy_definition" "require_costcenter" {
  name         = "northwind-require-costcenter"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Northwind - Audit Missing CosteCenter Tag"

  policy_rule = jsonencode({
    if = {
        field  = "tags['CostCenter']"
        exists = "false"
    }
    then = {
        effect = "deny"
    }
  })
}

# 2) Deny storage accounts that don't enforce HTTPS
resource "azurerm_policy_definition" "deny_http_storage" {
  name         = "northwind-deny-http-storage"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Northwind - Deny non-HTTPS storage accounts"

  policy_rule = jsonencode({
    if = {
      allOf = [
        { field = "type", equals = "Microsoft.Storage/storageAccounts" },
        { field = "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly", equals = "false" }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

# 3) Deny VM sizes outside the approved B-series list

resource "azurerm_policy_definition" "allowed_vm_skus" {
  name         = "northwind-allowed-vm-skus"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Northwind - Allowed VM SKUs"

  parameters = jsonencode({
    allowedSkus = {
      type = "Array"
      metadata = {
        displayName = "Allowed VM SKUs"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        { field = "type", equals = "Microsoft.Compute/virtualMachines" },
        { not = { field = "Microsoft.Compute/virtualMachines/sku.name", in = "[parameters('allowedSkus')]" } }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

# 4) Deny resources outside the approved regions
resource "azurerm_policy_definition" "allowed_locations" {
  name         = "northwind-allowed-locations"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Northwind - Allowed locations"

  parameters = jsonencode({
    allowedLocations = {
      type = "Array"
      metadata = {
        displayName = "Allowed locations"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        { field = "location", notIn = "[parameters('allowedLocations')]" },
        { field = "location", notEquals = "global" }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

# 5) Deny public IP addresses
resource "azurerm_policy_definition" "deny_public_ip" {
  name         = "northwind-audit-public-ip"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Northwind - Audit public IP addresses"

  policy_rule = jsonencode({
    if = {
      field  = "type"
      equals = "Microsoft.Network/publicIPAddresses"
    }
    then = {
      effect = "Deny"
    }
  })
}

# Deny resources missing the Environment tag
resource "azurerm_policy_definition" "require_environment" {
  name         = "northwind-require-environment"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Northwind - Deny missing Environment tag"

  policy_rule = jsonencode({
    if = {
      field  = "tags['Environment']"
      exists = "false"
    }
    then = {
      effect = "deny"
    }
  })
}

# Deny resources missing the Owner tag
resource "azurerm_policy_definition" "require_owner" {
  name         = "northwind-require-owner"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Northwind - Audit missing Owner tag"

  policy_rule = jsonencode({
    if = {
      field  = "tags['Owner']"
      exists = "false"
    }
    then = {
      effect = "deny"
    }
  })
}



#########################################################
# Initiative (Policy Set Definition)
#########################################################

resource "azurerm_policy_set_definition" "northwind_baseline" {
  name         = var.initiative_name
  policy_type  = "Custom"
  display_name = "Northwind Retail - Governance Baseline"
  description  = "Organization-wide governance baseline enforcing mandatory tagging, approved VM sizes, approved regions, HTTPS-only storage, and denial of Public IP resources."

  parameters = jsonencode({
    allowedSkus = {
        type = "Array"
        metadata = {
            displayName = "Allowed VM SKUs"
        }
      }
      allowedLocations = {
        type = "Array"
        metadata = {
            displayName = "Allowed locations"
        }
      }
   })

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_environment.id
    }
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_owner.id
    }
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_costcenter.id
    }
  policy_definition_reference { 
    policy_definition_id = azurerm_policy_definition.deny_http_storage.id
    }
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.allowed_vm_skus.id
    parameter_values = jsonencode({
        allowedSkus = { value = "[parameters('allowedSkus')]" }
    })
    }
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.allowed_locations.id
    parameter_values = jsonencode({
        allowedLocations = { value = "[parameters('allowedLocations')]" }
    })
    }
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.deny_public_ip.id
    }
}

#########################################################
# Assignment at Resource Group scope
#########################################################

resource "azurerm_resource_group_policy_assignment" "baseline" {
  name                 = var.assignment_name
  resource_group_id    = var.resource_group_id
  policy_definition_id = azurerm_policy_set_definition.northwind_baseline.id
  display_name         = "Northwind Governance Baseline"

  parameters = jsonencode({
    allowedSkus = { value = var.allowed_vm_skus }
    allowedLocations = { value = var.allowed_locations }
  })
}