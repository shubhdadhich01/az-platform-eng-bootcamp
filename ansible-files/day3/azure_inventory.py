#!/usr/bin/env python3

import json
import subprocess

RESOURCE_GROUP = "rg-northwind-prod"

# -------------------------------------------------
# Azure Virtual Machines
# -------------------------------------------------

vm_query = """
[].{
    name:name,
    ip:privateIps,
    tags:tags
}
"""

vm_cmd = [
    "az",
    "vm",
    "list",
    "-d",
    "-g",
    RESOURCE_GROUP,
    "--query",
    vm_query,
    "-o",
    "json"
]

vms = json.loads(subprocess.check_output(vm_cmd))

inventory = {
    "_meta": {
        "hostvars": {}
    },
    "all": {
        "hosts": []
    }
}

# -------------------------------------------------
# Add Azure VMs
# -------------------------------------------------

for vm in vms:

    hostname = vm["name"]
    ip = vm["ip"]

    inventory["all"]["hosts"].append(hostname)

    inventory["_meta"]["hostvars"][hostname] = {
        "ansible_host": ip,
        "ansible_user": "azureuser"
    }

    if "web" in hostname:
        inventory.setdefault("web", {"hosts": []})
        inventory["web"]["hosts"].append(hostname)

    elif "app" in hostname:
        inventory.setdefault("app", {"hosts": []})
        inventory["app"]["hosts"].append(hostname)


# -------------------------------------------------
# Discover VM Scale Sets
# -------------------------------------------------

vmss_cmd = [
    "az",
    "vmss",
    "list",
    "-g",
    RESOURCE_GROUP,
    "-o",
    "json"
]

vmss_list = json.loads(subprocess.check_output(vmss_cmd))

for vmss in vmss_list:

    vmss_name = vmss["name"]

    # Get NICs of all instances (contains private IP)
    nic_cmd = [
        "az",
        "vmss",
        "nic",
        "list",
        "-g",
        RESOURCE_GROUP,
        "--vmss-name",
        vmss_name,
        "-o",
        "json"
    ]

    nics = json.loads(subprocess.check_output(nic_cmd))

    for nic in nics:

        instance_id = nic["virtualMachine"]["id"].split("/")[-1]
        hostname = f"{vmss_name}-{instance_id}"

        ip = nic["ipConfigurations"][0]["privateIPAddress"]

        inventory["all"]["hosts"].append(hostname)

        inventory["_meta"]["hostvars"][hostname] = {
            "ansible_host": ip,
            "ansible_user": "azureuser"
        }

        # If VMSS name contains "web", place instances in web group
        if "web" in vmss_name.lower():
            inventory.setdefault("web", {"hosts": []})
            inventory["web"]["hosts"].append(hostname)

print(json.dumps(inventory, indent=2))