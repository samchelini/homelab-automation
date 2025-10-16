#!/bin/bash
set -e

# read from vars file if it exists
if [ -f ${BASH_SOURCE%/*}/.packer_vars ]; then
  source ${BASH_SOURCE%/*}/.packer_vars
fi

export PKR_VAR_vcenter_url
export PKR_VAR_vcenter_username
export PKR_VAR_vcenter_password

export PKR_VAR_vcenter_cluster
export PKR_VAR_vcenter_host
export PKR_VAR_vcenter_datastore
export PKR_VAR_vm_network
export PKR_VAR_vm_folder
export PKR_VAR_vm_disk_mb

export PKR_VAR_vm_ip
export PKR_VAR_vm_netmask
export PKR_VAR_vm_gateway
export PKR_VAR_vm_dns

echo -e "building image with packer...\n"

echo "checking vcenter vars..."
if [ -z "${PKR_VAR_vcenter_url}" ]; then
  read -p "  vcenter url: " PKR_VAR_vcenter_url
fi
if [ -z "${PKR_VAR_vcenter_username}" ]; then
  read -p "  vcenter username: " PKR_VAR_vcenter_username
fi
if [ -z "${PKR_VAR_vcenter_password}" ]; then
  read -s -p "  vcenter password: " PKR_VAR_vcenter_password
fi
echo -e "\n"

echo  "checking vm location and hardware vars..."
if [ -z "${PKR_VAR_vcenter_cluster}" ]; then
  read -p "  vcenter cluster: " PKR_VAR_vcenter_cluster
fi
if [ -z "${PKR_VAR_vcenter_host}" ]; then
  read -p "  vcenter host: " PKR_VAR_vcenter_host
fi
if [ -z "${PKR_VAR_vcenter_datastore}" ]; then
  read -p "  vcenter datastore: " PKR_VAR_vcenter_datastore
fi
if [ -z "${PKR_VAR_vm_network}" ]; then
  read -p "  vm network: " PKR_VAR_vm_network
fi
if [ -z "${PKR_VAR_vm_folder}" ]; then
  read -p "  vm folder: " PKR_VAR_vm_folder
fi
if [ -z "${PKR_VAR_vm_disk_mb}" ]; then
  read -p "  vm disk size (MB): " PKR_VAR_vm_disk_mb
fi
echo -e "\n"

echo "checking vm configuration..."
if [ -z "${PKR_VAR_vm_ip}" ]; then
  read -p "  vm ip: " PKR_VAR_vm_ip
fi
if [ -z "${PKR_VAR_vm_netmask}" ]; then
  read -p "  vm netmask: " PKR_VAR_vm_netmask
fi
if [ -z "${PKR_VAR_vm_gateway}" ]; then
  read -p "  vm gateway: " PKR_VAR_vm_gateway 
fi
if [ -z "${PKR_VAR_vm_dns}" ]; then
  read -p "  vm dns (space separated): " PKR_VAR_vm_dns
fi

packer init ${BASH_SOURCE%/*}/packer/debian/13
packer validate ${BASH_SOURCE%/*}/packer/debian/13
packer build -force ${BASH_SOURCE%/*}/packer/debian/13
