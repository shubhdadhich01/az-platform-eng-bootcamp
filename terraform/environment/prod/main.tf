#########################################################
# Day 1
#########################################################

module "virtual-network" {
    source              = "../../modules/day1/virtual-network"
    location            = var.location
    resource_group_name = local.naming.resource_group
    tags                = local.common_tags
    hub_vnet_name       = local.naming.hub_vnet
    hub_address_space   = [ "10.0.0.0/16" ]
    hub_subnets = {
      AzureFirewallSubnet = {address_prefixes = ["10.0.1.0/24"]}
      AzureBastionSubnet  = {address_prefixes = ["10.0.2.0/24"]}
      AnsibleSubnet       = {address_prefixes = ["10.0.3.0/24"]}
    }
    spoke_vnet_name     = local.naming.spoke_vnet
    spoke_address_space = [ "10.1.0.0/16" ]
    spoke_subnets = {
        web-subnet       = {address_prefixes = ["10.1.1.0/24"]}
        app-subnet       = {address_prefixes = ["10.1.2.0/24"]}
        private-endpoint = {address_prefixes = ["10.1.3.0/27"]}
    }
}

module "firewall" {
  depends_on = [ module.virtual-network ]
  source = "../../modules/day1/firewall"
  resource_group_name  = local.naming.resource_group
  location             = var.location
  firewall_name        = local.naming.firewall
  firewall_policy_name = local.naming.firewall_policy
  public_ip_name       = local.naming.firewall_public_ip
  hub_vnet_name        = local.naming.hub_vnet
  firewall_subnet_id   = module.virtual-network.hub_subnet["AzureFirewallSubnet"]
  tags                 = local.common_tags
}

module "route_table" {
  depends_on = [ module.virtual-network ]
  source              = "../../modules/day1/route-table"
  resource_group_name = local.naming.resource_group
  location            = var.location
  route_table_name    = local.naming.route_table_name
  firewall_private_ip = module.firewall.firewall.private_ip
  spoke_subnet_ids    = module.virtual-network.spoke_subnets
  tags                = local.common_tags
}

module "nsg" {
  depends_on = [ module.virtual-network ]
  source              = "../../modules/day1/nsg"
  resource_group_name = local.naming.resource_group
  location            = var.location
  web_nsg_name        = local.naming.web_nsg
  app_nsg_name        = local.naming.app_nsg
  web_subnet_id       = module.virtual-network.spoke_subnets["web-subnet"]
  app_subnet_id       = module.virtual-network.spoke_subnets["app-subnet"]
  web_subnet_cidr     = "10.1.1.0/24"
  app_subnet_cidr     = "10.1.2.0/24"
  bastion-subnet-cidr = "10.0.2.0/24"
  tags                = local.common_tags
}

module "bastion" {
  depends_on = [ module.virtual-network ]
  source                 = "../../modules/day1/bastion"
  resource_group_name    = local.naming.resource_group
  location               = var.location
  bastion_name           = local.naming.bastion
  bastion_public_ip_name = local.naming.bastion_public_ip
  bastion_subnet_id      = module.virtual-network.hub_subnet["AzureBastionSubnet"]
  tags                   = local.common_tags
}

module "compute" {
  depends_on = [ module.virtual-network ]
  source               = "../../modules/day1/compute"
  resource_group_name  = local.naming.resource_group
  location             = var.location
  web_vm_name          = local.naming.web_vm
  app_vm_name          = local.naming.app_vm
  web_nic_name         = local.naming.web_nic
  app_nic_name         = local.naming.app_nic
  web_subnet_id        = module.virtual-network.spoke_subnets["web-subnet"]
  app_subnet_id        = module.virtual-network.spoke_subnets["app-subnet"]
  vm_size              = "Standard_B1s"
  admin_username       = var.admin_username
  ssh_key              = file(pathexpand(var.ssh_public_key_path))
  storage_account_name = module.storage.storage_account_name
  container_name       = module.storage.container_name
  tags                 = local.common_tags
}

module "ansible" {
  depends_on = [ module.virtual-network ]
  source                 = "../../modules/day1/ansible-controller"
  resource_group_name    = local.naming.resource_group
  location               = var.location
  ansible_vm_name        = local.naming.ansible_vm_name
  ansible_nic_name       = local.naming.ansible_nic_name
  ansible_nsg_name       = local.naming.ansible_nsg_name
  ansible_subnet_id      = module.virtual-network.hub_subnet["AnsibleSubnet"]
  bastion_subnet_cidr    = "10.0.2.0/24"
  route_table_id         = module.route_table.route_table.id
  ansible_vm_size        = "Standard_B1s"
  ansible_admin_username = var.admin_username
  ansible_ssh_key        = file(pathexpand(var.ssh_public_key_path))
  web_vm_name            = local.naming.web_vm
  app_vm_name            = local.naming.app_vm
  app_private_ip         = module.compute.app_vm.private_ip
  web_private_ip         = module.compute.web_vm.private_ip
  tags                   = local.common_tags
}

#########################################################
# Day 2
#########################################################

module "log_analytics" {
  source              = "../../modules/day2/log-analytics"
  workspace_name      = local.naming.log_analytics_name
  location            = var.location
  resource_group_name = local.naming.resource_group
  log_retention_days  = var.log_retention_days
  tags                = local.common_tags
}

module "storage" {
  depends_on = [ module.virtual-network ]
  source               = "../../modules/day2/storage"
  storage_account_name = local.naming.storage_account_name
  container_name       = local.naming.blob_container_name
  location             = var.location
  resource_group_name  = local.naming.resource_group
  tags                 = local.common_tags
}

module "key-vault" {
  depends_on = [ module.virtual-network ]
  source              = "../../modules/day2/key-vault"
  key_vault_name      = local.naming.key_vault_name
  resource_group_name = local.naming.resource_group
  location            = var.location
  secret_name         = local.naming.application_secret_name
  secret_value        = var.secret_value
  tags                = local.common_tags
}

module "rbac" {
  depends_on = [ module.storage, module.key-vault ]
  source                 = "../../modules/day2/rbac"
  app_vm_principal_id    = module.compute.app_vm_principal_id
  key_vault_id           = module.key-vault.key_vault_id
  storage_container_id   = module.storage.storage_container_id
}

resource "time_sleep" "wait_for_rbac" {
  depends_on = [ module.rbac ]
  create_duration = "90s"
}

module "private-dns" {
  depends_on = [ module.virtual-network ]
  source              = "../../modules/day2/private-dns"
  resource_group_name = local.naming.resource_group
  location            = var.location
  storage_dns_name    = var.storage_dns_name
  key_vault_dns_name  = var.key_vault_dns_name
  hub_vnet_id         = module.virtual-network.hub_vnet_id
  spoke_vnet_id       = module.virtual-network.spoke_vnet_id
  hub_storage_link    = local.naming.sa_hub_link
  spoke_storage_link  = local.naming.sa_spoke_link
  hub_kv_link         = local.naming.kv_hub_link
  spoke_kv_link       = local.naming.kv_spoke_link
  tags                = local.common_tags
}

module "private-endpoint" {
  depends_on = [ module.virtual-network ]
  source                          = "../../modules/day2/private-endpoint"
  sa_private_endpoint_name        = local.naming.sa_private_endpoint_name
  key_vault_private_endpoint_name = local.naming.key_vault_private_endpoint_name
  location                        = var.location
  resource_group_name             = local.naming.resource_group
  private_endpoint_subnet_id      = module.virtual-network.spoke_subnets["private-endpoint"]
  storage_account_id              = module.storage.storage_account_id
  key_vault_id                    = module.key-vault.key_vault_id
  sa_private_dns_zone_id          = module.private-dns.sa_private_dns_zone_id
  kv_private_dns_zone_id          = module.private-dns.kv_private_dns_zone_id
}

module "log-diagnostics" {
  depends_on = [ module.storage, module.key-vault ]
  source                     = "../../modules/day2/log-diagnostics"
  storage_diagnostics_name   = local.naming.storage_diagnostics_name
  key_vault_diagnostics_name = local.naming.key_vault_diagnostics_name
  log_analytics_id           = module.log_analytics.log_workspace_id
  storage_account_id         = module.storage.storage_account_id
  key_vault_id               = module.key-vault.key_vault_id
}

module "key-vault-secret" {
  depends_on = [ module.rbac, module.key-vault, time_sleep.wait_for_rbac ]
  source = "../../modules/day2/key-vault-secret"
  secret_name         = local.naming.application_secret_name
  secret_value        = var.secret_value
  key_vault_id        = module.key-vault.key_vault_id
}

#########################################################
# Day 3
#########################################################

#########################################################
# Day 4
#########################################################

#########################################################
# Day 5
#########################################################

#########################################################
# Day 6
#########################################################

#########################################################
# Day 7
#########################################################