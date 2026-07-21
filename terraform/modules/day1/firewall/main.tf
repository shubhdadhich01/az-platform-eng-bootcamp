#########################################################
# Public IP
#########################################################

resource "azurerm_public_ip" "firewall_ip" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

#########################################################
# Firewall Policy
#########################################################

resource "azurerm_firewall_policy" "firewall_policy" {
  name                = var.firewall_policy_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  tags                = var.tags
}

#########################################################
# Rule Collection Group
#########################################################

resource "azurerm_firewall_policy_rule_collection_group" "firewall_policy_rule" {
  name               = "DefaultRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.firewall_policy.id
  priority           = 100

  network_rule_collection {
    name     = "AllowNetworkTraffic"
    priority = 100
    action   = "Allow"
    rule {
        name                  = "Allow-DNS"
        protocols             = ["UDP","TCP"]
        source_addresses      = ["*"]
        destination_ports     = [53]
        destination_addresses = ["*"]
    }
    rule {
        name                  = "Allow-HTTP"
        protocols             = ["TCP"]
        source_addresses      = ["*"]
        destination_ports     = [80]
        destination_addresses = ["*"]
    }
    rule {
        name                  = "Allow-HTTPS"
        protocols             = ["TCP"]
        source_addresses      = ["*"]
        destination_ports     = [443]
        destination_addresses = ["*"]
    }
  }

  application_rule_collection {
    name     = "AllowApplicationTraffic"
    priority = 200
    action   = "Allow"
    rule {
        name = "Allow-GitHub-ubuntu-microsoft"
        source_addresses = ["*"]
        destination_fqdns = ["github.com",
                             "archive.ubuntu.com",
                             "security.ubuntu.com",
                             "packages.microsoft.com"]
        protocols {
          type = "Https"
          port = 443
        }
    }
  }
}

#########################################################
# Azure Firewall
#########################################################

resource "azurerm_firewall" "firewall" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.firewall_policy.id
  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.firewall_ip.id
  }
}