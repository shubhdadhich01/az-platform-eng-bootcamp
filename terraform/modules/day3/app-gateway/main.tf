data "azurerm_client_config" "current" {}

#########################################################
# Application Gateway Subnet (dedicated, no firewall UDR)
#########################################################

resource "azurerm_subnet" "appgw-subnet" {
  name                 = var.appgw_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.spoke_vnet_name
  address_prefixes     = [var.appgw_subnet_cidr]
}

#########################################################
# Application Gateway NSG (GatewayManager + client 80/443)
#########################################################

resource "azurerm_network_security_group" "appgw-nsg" {
  name                = var.appgw_nsg_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_network_security_rule" "allow-gateway-manager" {
  name                        = "Allow-Gateway-Manager"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["65200-65535"]
  source_address_prefix       = "GatewayManager"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.appgw-nsg.name
}

resource "azurerm_network_security_rule" "allow-azure-lb" {
  name                        = "Allow-AzureLoadBalancer"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = [80, 443]
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.appgw-nsg.name
}

resource "azurerm_network_security_rule" "allow-client-web" {
  name                        = "Allow-internet-HTTP-HTTPS"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = [80, 443]
  source_address_prefix       = "internet"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.appgw-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "appgw-association" {
  subnet_id                 = azurerm_subnet.appgw-subnet.id
  network_security_group_id = azurerm_network_security_group.appgw-nsg.id
}

#########################################################
# Public IP (Standard, Static)
#########################################################

resource "azurerm_public_ip" "appgw_ip" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

#########################################################
# User-Assigned Identity (App Gateway -> Key Vault cert)
#########################################################

resource "azurerm_user_assigned_identity" "appgw-identity" {
  name                = var.identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

#########################################################
# WAF Policy (OWASP CRS, Prevention mode)
#########################################################

resource "azurerm_web_application_firewall_policy" "waf" {
  name                = var.waf_policy_name
  location            = var.location
  resource_group_name = var.resource_group_name

  policy_settings {
    enabled = true
    mode    = "Prevention"
  }

  managed_rules {
    managed_rule_set {
        type    = "OWASP"
        version = "3.2"
     }
   }
  tags = var.tags
}

#########################################################
# Application Gateway (WAF_v2, autoscale 1-2)
#########################################################

resource "azurerm_application_gateway" "appgw" {
  name                = var.appgw_name
  location            = var.location
  resource_group_name = var.resource_group_name
  firewall_policy_id  = azurerm_web_application_firewall_policy.waf.id
  tags                = var.tags

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 2 
  }

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.appgw-identity.id]
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.appgw-subnet.id
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_config
    public_ip_address_id = azurerm_public_ip.appgw_ip.id
  }

  frontend_port {
    name = local.frontend_port_http
    port = 80
  }

  frontend_port {
    name = local.frontend_port_https
    port = 443
  }

  ssl_certificate {
    name                = local.ssl_cert_name
    key_vault_secret_id = var.key_vault_certificate_secret_id
  }

  backend_address_pool {
    name = local.backend_pool
  }

  probe {
    name                = local.probe-name
    protocol            = "Http"
    path                = var.health_probe_path
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    pick_host_name_from_backend_http_settings = true
    match {status_code = ["200-399"]}
  }

  backend_http_settings {
    name                  = local.backend_http_settings
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = local.probe-name
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = local.http_listner
    frontend_ip_configuration_name = local.frontend_ip_config
    frontend_port_name             = local.frontend_port_http
    protocol                       = "Http"
  }

  http_listener {
    name                           = local.https_listner
    frontend_ip_configuration_name = local.frontend_ip_config
    frontend_port_name             = local.frontend_port_https
    protocol                       = "Https"
     ssl_certificate_name          = local.ssl_cert_name
  }

  redirect_configuration {
    name                 = local.redirect_config
    redirect_type        = "Permanent"
    target_listener_name = local.https_listner
    include_path         = true
    include_query_string = true
  }

  request_routing_rule {
    name                        = "http-redirect-rule"
    priority                    = 10
    rule_type                   = "Basic"
    http_listener_name          = local.http_listner
    redirect_configuration_name = local.redirect_config
  }

  request_routing_rule {
    name                        = "https-redirect-rule"
    priority                    = 20
    rule_type                   = "Basic"
    http_listener_name          = local.https_listner
    backend_address_pool_name   = local.backend_pool
    backend_http_settings_name  = local.backend_http_settings
  }

  # VMSS instances register themselves into this pool, so ignore drift on it
  lifecycle {
    ignore_changes = [ backend_address_pool ]
  }
}
