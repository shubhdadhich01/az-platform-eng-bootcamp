locals {

  naming = {

    resource_group = format(
      "rg-%s-%s",
      var.project_name,
      var.environment
    )

    hub_vnet = format(
      "vnet-hub-%s",
      var.environment
    )

    spoke_vnet = format(
      "vnet-spoke-%s",
      var.environment
    )

    firewall = format(
      "afw-%s-%s",
      var.project_name,
      var.environment
    )
    
    firewall_public_ip = format(
      "pip-afw-%s",
       var.environment
    )

    firewall_policy = format(
      "afwp-%s-%s",
      var.project_name,
      var.environment
    )

    bastion = format(
      "bas-%s-%s",
      var.project_name,
      var.environment
    )

    bastion_public_ip = format(
      "pip-bas-%s",
      var.environment
    )

    web_vm = format(
      "vm-web-%s",
      var.environment
    )

    app_vm = format(
      "vm-app-%s",
      var.environment
    )

    web_nic = format(
      "vm-web-%s",
       var.environment
    )

    app_nic = format(
      "vm-app-%s",
       var.environment
    )

    web_nsg = format(
      "nsg-web-%s",
      var.environment
    )

    app_nsg = format(
      "nsg-app-%s",
      var.environment
    )

    ansible_vm_name = format(
      "ansible-vm-%s",
      var.environment
    )

    ansible_nic_name = format(
      "ansible-nic-%s",
      var.environment
    )

    ansible_nsg_name = format(
      "ansible-nsg-%s",
      var.environment
    )

    route_table_name = format(
      "spoke-rt-%s",
      var.environment
    )

    #####################################################
    # Day 2
    #####################################################

    log_analytics_name = format(
      "log-analytics-%s",
      var.environment
    )

    storage_account_name = format(
      "%s%ssa",
      var.project_name,
      var.environment
    )

    blob_container_name = format(
      "application-data-%s",
      var.environment
    )

    key_vault_name = format(
      "key-vault-%s-%s",
      var.project_name,
      var.environment
    )

    application_secret_name = format(
      "db-passowrd-%s",
      var.environment
    )

    sa_hub_link = format(
      "sa-hub-link-%s",
      var.environment
    )

    sa_spoke_link = format(
      "sa-spoke-link-%s",
      var.environment
    )

    kv_hub_link = format(
      "kv-hub-link-%s",
      var.environment
    )

    kv_spoke_link = format(
      "kv-spoke-link-%s",
      var.environment
    )

    sa_private_endpoint_name = format(
      "sa-private-endpoint-%s",
      var.environment
    )
    key_vault_private_endpoint_name = format(
      "kv-private-endpoint-%s",
      var.environment
    )

    storage_diagnostics_name = format(
      "sa-diagnostics-%s",
      var.environment
    )

    key_vault_diagnostics_name = format(
      "kv-diagnostics-%s",
      var.environment
    )

    #####################################################
    # Day 3
    #####################################################

    web_vmss_name = format(
      "vmss-web-%s",
      var.environment
    )

    appgw_subnet_name = format(
      "appgw-subnet-%s",
      var.environment
    )

    appgw_nsg_name = format(
      "nsg-appgw-%s",
      var.environment
    )

    appgw_public_ip = format(
      "pip-appgw-%s",
      var.environment
    )

    appgw_indentity_name = format(
      "appgw-identity-%s",
      var.environment
    )

    appgw_cert_name = format(
      "appgw-cert-%s",
      var.environment
    )

    waf_policy_name = format(
      "wafp-%s-%s",
      var.project_name,
      var.environment
    )

    appgw_name = format(
      "agw-%s-%s",
      var.project_name,
      var.environment
    )

    #####################################################
    # Day 4
    #####################################################

    action_group_name = format(
      "ag-secops-%s",
      var.environment
    )

    jit_alert_name = format(
      "alert-jit-request-%s",
      var.environment
    )

    jit_policy_name = format(
      "jit-policy-%s",
      var.environment
    )

    monitor_dcr_name = format(
      "monitor-dcr-%s",
      var.environment
    )

    #####################################################
    # Day 5
    #####################################################

    cmk_name = format(
     "cmk-%s-%s",
      var.project_name,
      var.environment
    )

    des_name = format(
      "des-%s-%s",
      var.project_name,
      var.environment
    )

    des_identity_name = format(
      "des-identity-%s",
      var.environment
    )

    encrypted_disk_name = format(
      "app-disk-%s",
      var.environment
    )
  }

  common_tags = {

    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner

    ManagedBy = "Terraform"

    CostCenter = "Retail"

    LandingZone = "Hub-Spoke"

    CreatedBy = "Bootcamp"

  }

}