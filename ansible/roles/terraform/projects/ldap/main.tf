locals {
  ds1 = {
    num_cpus     = 1
    memory_mb    = 512
    disk_size_gb = 16
    metadata = {
      vm_name    = "ds1"
      vm_domain  = var.vm_domain
      vm_cidr    = "10.0.20.7/24"
      vm_gateway = "10.0.20.1"
      vm_dns     = "10.0.20.5, 10.0.20.6"
    }
    userdata = {
      ansible_public_ssh_key = var.ansible_public_ssh_key
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "datacenter" {
  name = var.datacenter_name
}

data "vsphere_virtual_machine" "template" {
  name          = "/${var.datacenter_name}/vm/packer_templates/${var.template_name}"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore_cluster" "datastore_cluster" {
  name          = var.datastore_cluster_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "resource_pool" {
  name          = var.resource_pool_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "ds1" {
  name                 = local.ds1.metadata.vm_name
  resource_pool_id     = data.vsphere_resource_pool.resource_pool.id
  datastore_cluster_id = data.vsphere_datastore_cluster.datastore_cluster.id
  folder               = "/${var.datacenter_name}/vm/${var.folder_name}"
  num_cpus             = local.ds1.num_cpus
  memory               = local.ds1.memory_mb
  guest_id             = var.guest_id
  network_interface {
    network_id = data.vsphere_network.network.id
  }
  disk {
    label            = "Hard Disk 1"
    thin_provisioned = true
    size             = local.ds1.disk_size_gb
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  extra_config = {
    "guestinfo.metadata"          = base64gzip(templatefile("${var.role_path}/templates/metadata.tftpl", local.ds1.metadata))
    "guestinfo.metadata.encoding" = "gzip+base64"
    "guestinfo.userdata"          = base64gzip(templatefile("${var.role_path}/templates/userdata.tftpl", local.ds1.userdata))
    "guestinfo.userdata.encoding" = "gzip+base64"
  }
}
