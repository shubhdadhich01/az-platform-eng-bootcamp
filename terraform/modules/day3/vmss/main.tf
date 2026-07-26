#########################################################
# Linux Virtual Machine Scale Set (Web)
#########################################################

resource "azurerm_linux_virtual_machine_scale_set" "web-vmss" {
 name                            = var.web_vmss_name
 location                        = var.location
 resource_group_name             = var.resource_group_name
 sku                             = var.vmss_size
 instances                       = var.instance_count
 admin_username                  = var.admin_username
 disable_password_authentication = true
 upgrade_mode                    = "Automatic"

 admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
   
   network_interface {
    name    = "${var.web_vmss_name}-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.web_subnet_id
      # App Gateway backend pool attachment (populated after App Gateway exists)
      application_gateway_backend_address_pool_ids = var.backend_pool_ids
    }
  }

  custom_data = base64encode(templatefile("${path.module}/cloud-init.yml.tftpl", {}))
  tags = var.tags
}

#########################################################
# CPU-Based Autoscale (min 1 / max 2)
#########################################################

resource "azurerm_monitor_autoscale_setting" "web-vmss-autoscale" {
  name                = "${var.web_vmss_name}-autoscale"
  location            = var.location
  resource_group_name = var.resource_group_name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.web-vmss.id
  tags                = var.tags

  profile {
    name = "cpu-autoscale"
    capacity {
        minimum = var.min_instances
        maximum = var.max_instances
        default = var.min_instances
    }

    rule {
        metric_trigger {
         metric_name        = "Percentage CPU"
         metric_resource_id = azurerm_linux_virtual_machine_scale_set.web-vmss.id
         time_grain         = "PT1M"
         statistic          = "Average"
         time_window        = "PT5M"
         time_aggregation   = "Average"
         operator           = "GreaterThan"
         threshold          = 75
        }
        scale_action {
            direction = "Increase"
            type      = "ChangeCount"
            value     = "1"
            cooldown  = "PT5M"
      }
    }

    rule {
        metric_trigger {
            metric_name        = "Percentage CPU"
            metric_resource_id = azurerm_linux_virtual_machine_scale_set.web-vmss.id
            time_grain         = "PT1M"
            statistic          = "Average"
            time_window        = "PT5M"
            time_aggregation   = "Average"
            operator           = "LessThan"
            threshold          = 25
        }
        scale_action {
            direction = "Decrease"
            type      = "ChangeCount"
            value     = "1"
            cooldown  = "PT5M"
       }
    } 
  }
}