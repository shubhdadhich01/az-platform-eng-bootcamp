#########################################################
# Web Tier Network Security Group
#########################################################

resource "azurerm_network_security_group" "web-nsg" {
  name                = var.web_nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = var.tags
}

#########################################################
# Allow SSH From Azure Bastion
#########################################################

resource "azurerm_network_security_rule" "bastion-to-web" {
  name                        = "Allow-bastion-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  destination_address_prefix  = "*"
  source_address_prefix       = var.bastion-subnet-cidr
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.web-nsg.name
}

#########################################################
# Allow HTTP To Web Tier
#########################################################

resource "azurerm_network_security_rule" "web-allow-http" {
  name                        = "Allow-HTTP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "virtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.web-nsg.name
}

#########################################################
# Deny other inbonds To Web Tier
#########################################################

resource "azurerm_network_security_rule" "web_deny_other_inbound" {
  name                       = "Deny-Other-Inbound"
  priority                   = 4096
  direction                  = "Inbound"
  access                     = "Deny"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.web-nsg.name
}

#########################################################
# Allow Ansible SSH To Web Tier
#########################################################

resource "azurerm_network_security_rule" "ansible-ssh-web" {
  name                        = "Allow-Ansible-SSH"
  priority                    = 111
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "10.0.3.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.web-nsg.name
}

#########################################################
# App Tier Network Security Group
#########################################################

resource "azurerm_network_security_group" "app-nsg" {
  name                = var.app_nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

#########################################################
# Allow SSH From Azure Bastion
#########################################################

resource "azurerm_network_security_rule" "bastion-to-app" {
  name                        = "Allow-bastion-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  destination_address_prefix  = "*"
  source_address_prefix       = var.bastion-subnet-cidr
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.app-nsg.name
}

#########################################################
# Allow Backend Traffic Only From Web Subnet
#########################################################

resource "azurerm_network_security_rule" "app-allow-web" {
  name                        = "Allow-web-to-app"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  destination_address_prefix  = "*"
  source_address_prefix       = var.web_subnet_cidr
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.app-nsg.name
}

#########################################################
# Allow Backend Traffic Only From Web Subnet(8080)
#########################################################

resource "azurerm_network_security_rule" "allow_web_to_app_8080" {
  name                        = "Allow-web-to-app-8080"
  priority                    = 113
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  destination_address_prefix  = "*"
  source_address_prefix       = var.web_subnet_cidr
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.app-nsg.name
}

#########################################################
# Deny other inbonds To app Tier
#########################################################

resource "azurerm_network_security_rule" "app_deny_other_inbound" {
  name                       = "Deny-Other-Inbound"
  priority                   = 4096
  direction                  = "Inbound"
  access                     = "Deny"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.app-nsg.name
}

#########################################################
# Allow Ansible SSH To app Tier
#########################################################

resource "azurerm_network_security_rule" "ansible-ssh-app" {
  name                        = "Allow-Ansible-SSH"
  priority                    = 112
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "10.0.3.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.app-nsg.name
}

#########################################################
# Associate Web NSG With Web Subnet
#########################################################

resource "azurerm_subnet_network_security_group_association" "web-association" {
  subnet_id                 = var.web_subnet_id
  network_security_group_id = azurerm_network_security_group.web-nsg.id
}

#########################################################
# Associate App NSG With App Subnet
#########################################################

resource "azurerm_subnet_network_security_group_association" "app-association" {
  subnet_id                 = var.app_subnet_id
  network_security_group_id = azurerm_network_security_group.app-nsg.id
}

