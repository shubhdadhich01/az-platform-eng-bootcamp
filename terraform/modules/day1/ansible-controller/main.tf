#########################################################
# Ansible Controller NSG
#########################################################

resource "azurerm_network_security_group" "ansible-nsg" {
  name                = var.ansible_nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

#########################################################
# Allow SSH From Azure Bastion
#########################################################

resource "azurerm_network_security_rule" "ansible-nsg-rule" {
  name                        = "Allow-Bastion-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.bastion_subnet_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.ansible-nsg.name
}

#########################################################
# Deny Remaining Inbound Traffic
#########################################################

resource "azurerm_network_security_rule" "deny-other-inbound" {
  name                        = "Deny-Other-inbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.ansible-nsg.name
}

#########################################################
# Associate NSG With Ansible Subnet
#########################################################

resource "azurerm_subnet_network_security_group_association" "anible-nsg-association" {
  subnet_id                 = var.ansible_subnet_id
  network_security_group_id = azurerm_network_security_group.ansible-nsg.id
}

#########################################################
# Associate Central Egress Route Table
#########################################################

resource "azurerm_subnet_route_table_association" "anible-rt-association" {
  subnet_id                 = var.ansible_subnet_id
  route_table_id            = var.route_table_id
}

#########################################################
# Ansible Controller NIC
#########################################################

resource "azurerm_network_interface" "ansible-nic" {
  name                = var.ansible_nic_name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "ansible-ip-configuration"
    subnet_id                     = var.ansible_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

#########################################################
# Ansible Controller VM
#########################################################

resource "azurerm_linux_virtual_machine" "ansible-vm" {
  name                            = var.ansible_vm_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.ansible_vm_size
  admin_username                  = var.ansible_admin_username
  disable_password_authentication = true
  network_interface_ids           = [ azurerm_network_interface.ansible-nic.id ]
  admin_ssh_key {
    username   = var.ansible_admin_username
    public_key = var.ansible_ssh_key
  }
  os_disk {
    caching              = "ReadWrite"
    name                 = "${var.ansible_vm_name}-osdisk"
    storage_account_type = "Standard_LRS"
    }
  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  custom_data = base64encode(templatefile(
    "${path.module}/cloud-init.yml.tftpl",
    {
      web_vm_name            = var.web_vm_name
      web_private_ip         = var.web_private_ip
      app_vm_name            = var.app_vm_name
      app_private_ip         = var.app_private_ip
      ansible_admin_username = var.ansible_admin_username
    }
  ))
  tags = var.tags
}