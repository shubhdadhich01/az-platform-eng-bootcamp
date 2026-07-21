#########################################################
# Azure Bastion Public IP
#########################################################

resource "azurerm_public_ip" "bastion_ip" {
  name = var.bastion_public_ip_name
  location = var.location
  resource_group_name = var.resource_group_name
  allocation_method = "Static"
  sku = "Standard"
  tags = var.tags
}

#########################################################
# Azure Bastion Host
#########################################################

resource "azurerm_bastion_host" "bastion" {
  name = var.bastion_name
  location = var.location
  resource_group_name = var.resource_group_name
  sku = "Basic"

  ip_configuration {
    name = var.bastion_public_ip_name
    subnet_id = var.bastion_subnet_id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
  }

  tags = var.tags
}

