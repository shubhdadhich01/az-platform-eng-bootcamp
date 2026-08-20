#########################################################
# Delegated Subnet for Function VNet Integration
#########################################################

resource "azurerm_subnet" "func_subnet" {
  name                 = var.func_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.spoke_vnet_name
  address_prefixes     = [var.func_subnet_cidr]
  
  delegation {
    name = "func-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

#########################################################
# Storage Account (Function runtime backing store)
#########################################################

resource "azurerm_storage_account" "func_storage" {
  name                     = var.func_storage_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

#########################################################
# Consumption Plan (Y1, Linux)
#########################################################

resource "azurerm_service_plan" "func_plan" {
  name                = var.plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "EP1"
  tags                = var.tags
}

#########################################################
# Application Insights (workspace-based)
#########################################################

resource "azurerm_application_insights" "func_ai" {
  name                = var.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = var.log_analytics_id
  tags                = var.tags
}

#########################################################
# Linux Function App with VNet Integration
#########################################################

resource "azurerm_linux_function_app" "manifest_processor" {
  name                = var.function_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.func_plan.id

  storage_account_name       = azurerm_storage_account.func_storage.name
  storage_account_access_key = azurerm_storage_account.func_storage.primary_access_key

  virtual_network_subnet_id  = azurerm_subnet.func_subnet.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    vnet_route_all_enabled = true
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.func_ai.connection_string
    MANIFEST_STORAGE_ACCOUNT              = var.data_storage_account_name
    MANIFEST_CONTAINER                    = var.data_container_name
  }

  tags = var.tags
}