#########################################################
# Web Tier Network Interface
#########################################################

resource "azurerm_network_interface" "web-nic" {
  name                = var.web_nic_name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name = "web-ip-configuration"
    subnet_id = var.web_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

#########################################################
# app Tier Network Interface
#########################################################

resource "azurerm_network_interface" "app-nic" {
  name                = var.app_nic_name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name = "app-ip-configuration"
    subnet_id = var.app_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

#########################################################
# Web Tier Linux VM
#########################################################

resource "azurerm_linux_virtual_machine" "web-vm" {
  name                            = var.web_vm_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.web-nic.id]
  admin_ssh_key {
    username = var.admin_username
    public_key = var.ssh_key
  }

  os_disk {
    name                 = "${var.web_vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "ubuntu-24_04-lts"
    sku = "server"
    version = "latest"
  }
  tags = var.tags
}

#########################################################
# App Tier Linux VM
#########################################################


resource "azurerm_linux_virtual_machine" "app-vm" {
  name                            = var.app_vm_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.app-nic.id]
  admin_ssh_key {
    username = var.admin_username
    public_key = var.ssh_key
  }

  os_disk {
    name                 = "${var.app_vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  custom_data = base64encode(templatefile(
    "${path.module}/cloud-init.yml.tftpl",
    {
      storage_account_name   = var.storage_account_name
      container_name         = var.container_name
    }
  ))
  
  tags = var.tags
}

