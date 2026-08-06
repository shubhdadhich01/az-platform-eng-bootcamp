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
  resource_group_id      = module.virtual-network.resource_group_id
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
  #day4
  storage_identity_id  = module.encryption-rbac.storage_identity_id
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
  #day6
  tags                            = local.common_tags
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

module "app-gateway" {
  depends_on = [ module.virtual-network ]
  source                          = "../../modules/day3/app-gateway"
  resource_group_name             = local.naming.resource_group
  location                        = var.location
  spoke_vnet_name                 = module.virtual-network.spoke_vnet_name
  appgw_subnet_name               = local.naming.appgw_subnet_name
  appgw_subnet_cidr               = "10.1.4.0/24"
  appgw_nsg_name                  = local.naming.appgw_nsg_name
  public_ip_name                  = local.naming.appgw_public_ip
  identity_name                   = local.naming.appgw_indentity_name
  waf_policy_name                 = local.naming.waf_policy_name
  appgw_name                      = local.naming.appgw_name
  cert_vault_name                 = module.key-vault.key_vault_name
  key_vault_certificate_secret_id = module.certificate-rbac.key_vault_certificate_secret_id
  tags                            = local.common_tags

}

module "certificate-rbac" {
  depends_on = [ module.key-vault, module.rbac ]
  source             = "../../modules/day3/certificates-rbac"
  key_vault_id       = module.key-vault.key_vault_id
  cert_name          = local.naming.appgw_cert_name
  appgw_indentity_id = module.app-gateway.appgw_principal_id
}

module "vmss" {
  depends_on = [ module.app-gateway ]
  source              = "../../modules/day3/vmss"
  resource_group_name = local.naming.resource_group
  location            = var.location
  web_vmss_name       = local.naming.web_vmss_name
  vmss_size           = "Standard_B1s"
  admin_username      = var.admin_username
  ssh_key             = file(pathexpand(var.ssh_public_key_path))
  web_subnet_id       = module.virtual-network.spoke_subnets["web-subnet"]
  backend_pool_ids    = [module.app-gateway.backend_pool_id]
  tags                = local.common_tags
}

#########################################################
# Day 4
#########################################################

module "montitor-alert" {
  depends_on = [ module.virtual-network ]
  source              = "../../modules/day4/monitor-alert"
  resource_group_name = local.naming.resource_group
  action_group_name   = local.naming.action_group_name
  notification_email  = var.notification_email
  alert_name          = local.naming.jit_alert_name
  tags                = local.common_tags
}

module "jit-access" {
  depends_on = [ module.compute ]
  source                = "../../modules/day4/jit-access"
  jit_policy_name       = local.naming.jit_policy_name
  enabled               = var.enable_jit
  enable_defender_plan  = var.enable_defender_plan
  resource_group_name   = local.naming.resource_group
  location              = var.location
  vm_ids                = [module.compute.web_vm.id, module.compute.app_vm.id]
}

module "monitor-dcr" {
  depends_on = [ module.compute ]
  source                     = "../../modules/day4/monitor-dcr"
  monitor_dcr_name           = local.naming.monitor_dcr_name
  location                   = var.location
  resource_group_name        = local.naming.resource_group
  log_analytics_workspace_id = module.log_analytics.log_workspace_id
  vm_ids = {
    ansible = module.ansible.ansible-Controller.id
    web     = module.compute.web_vm.id
    app     = module.compute.app_vm.id
  }
}

#########################################################
# Day 5
#########################################################

module "cmk"{
  depends_on = [ module.key-vault, module.rbac ]
  source       = "../../modules/day5/cmk"
  cmk_name     = local.naming.cmk_name
  key_vault_id = module.key-vault.key_vault_id
  tags         = local.common_tags

}

module "disk-encryption" {
  depends_on = [ module.cmk, module.compute, module.encryption-rbac ]
  source              = "../../modules/day5/disk-encryption"
  resource_group_name = local.naming.resource_group
  location            = var.location
  vm_id               = module.compute.app_vm.id
  key_vault_key_id    = module.cmk.versionless_key_id
  des_name            = local.naming.des_name
  disk_name           = local.naming.encrypted_disk_name
  des_identity_id     = module.encryption-rbac.des_identity_id
  tags                = local.common_tags
}

module "storage-disk" {
  depends_on = [ module.cmk, module.storage, module.encryption-rbac ]
  source                    = "../../modules/day5/storage-disk"
  storage_account_id        = module.storage.storage_account_id
  key_vault_key_id          = module.cmk.cmk_id
  user_assigned_identity_id = module.encryption-rbac.storage_identity_id
}

module "encryption-rbac" {
  depends_on = [ module.key-vault ]
  source               = "../../modules/day5/rbac"
  key_vault_id         = module.key-vault.key_vault_id
  des_identity_name   = local.naming.des_identity_name
  storage_account_name = local.naming.storage_account_name
  ansible_vm_principal_id = module.ansible.ansible_vm_principal_id
  resource_group_name = local.naming.resource_group
  location            = var.location
  tags                = local.common_tags
}

#########################################################
# Day 6
#########################################################

module "policy-govenanace" {
  depends_on = [ module.virtual-network ]
  source            = "../../modules/day6/policy-governance"
  initiative_name   = local.naming.policy_initiative_name
  assignment_name   = local.naming.policy_assignment_name
  resource_group_id = module.virtual-network.resource_group_id
  allowed_locations = ["centralindia"]
  allowed_vm_skus   = ["Standard_B1s", "Standard_B2s"]
}

#########################################################
# Day 7
#########################################################

module "function-app" {
  depends_on = [ module.storage, module.virtual-network, module.log_analytics, module.virtual-network ]
  source                    = "../../modules/day7/function-app"
  resource_group_name       = local.naming.resource_group
  location                  = var.location
  spoke_vnet_name           = module.virtual-network.spoke_vnet_name
  func_subnet_name          = local.naming.func_subnet_name
  func_subnet_cidr          = "10.1.5.0/24"
  func_storage_name         = local.naming.func_storage_name
  plan_name                 = local.naming.func_plan_name
  app_insights_name         = local.naming.func_app_insights_name
  function_app_name         = local.naming.function_app_name
  log_analytics_id          = module.log_analytics.log_workspace_id
  data_storage_account_name = module.storage.storage_account_name
  data_container_name       = module.storage.container_name
  data_container_id         = module.storage.storage_container_id
  key_vault_id              = module.key-vault.key_vault_id
  storage_container_id      = module.storage.storage_container_id
  ansible_vm_principle_id   = module.ansible.ansible_vm_principal_id
  tags                      = local.common_tags
}