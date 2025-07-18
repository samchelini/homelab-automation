locals {
  ns1 = {
    num_cpus     = 1
    memory_mb    = 512
    disk_size_gb = 16
    metadata = {
      vm_name    = "ns1"
      vm_domain  = var.vm_domain
      vm_cidr    = "10.0.20.5/24"
      vm_gateway = "10.0.20.1"
      vm_dns     = "8.8.8.8, 8.8.4.4"
    }
    userdata = {
      ansible_public_ssh_key = var.ansible_public_ssh_key
    }
  }

  ns2 = {
    num_cpus     = 1
    memory_mb    = 512
    disk_size_gb = 16
    metadata = {
      vm_name    = "ns2"
      vm_domain  = var.vm_domain
      vm_cidr    = "10.0.20.6/24"
      vm_gateway = "10.0.20.1"
      vm_dns     = "8.8.8.8, 8.8.4.4"
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

resource "vsphere_virtual_machine" "ns1" {
  name                 = local.ns1.metadata.vm_name
  resource_pool_id     = data.vsphere_resource_pool.resource_pool.id
  datastore_cluster_id = data.vsphere_datastore_cluster.datastore_cluster.id
  folder               = "/${var.datacenter_name}/vm/${var.folder_name}"
  num_cpus             = local.ns1.num_cpus
  memory               = local.ns1.memory_mb
  guest_id             = var.guest_id
  network_interface {
    network_id = data.vsphere_network.network.id
  }
  disk {
    label            = "Hard Disk 1"
    thin_provisioned = true
    size             = local.ns1.disk_size_gb
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  extra_config = {
    "guestinfo.metadata"          = base64gzip(templatefile("${var.role_path}/templates/metadata.tftpl", local.ns1.metadata))
    "guestinfo.metadata.encoding" = "gzip+base64"
    "guestinfo.userdata"          = base64gzip(templatefile("${var.role_path}/templates/userdata.tftpl", local.ns1.userdata))
    "guestinfo.userdata.encoding" = "gzip+base64"
  }
}

resource "vsphere_virtual_machine" "ns2" {
  name                 = local.ns2.metadata.vm_name
  resource_pool_id     = data.vsphere_resource_pool.resource_pool.id
  datastore_cluster_id = data.vsphere_datastore_cluster.datastore_cluster.id
  folder               = "/${var.datacenter_name}/vm/${var.folder_name}"
  num_cpus             = local.ns2.num_cpus
  memory               = local.ns2.memory_mb
  guest_id             = var.guest_id
  network_interface {
    network_id = data.vsphere_network.network.id
  }
  disk {
    label            = "Hard Disk 1"
    thin_provisioned = true
    size             = local.ns2.disk_size_gb
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  extra_config = {
    "guestinfo.metadata"          = base64gzip(templatefile("${var.role_path}/templates/metadata.tftpl", local.ns2.metadata))
    "guestinfo.metadata.encoding" = "gzip+base64"
    "guestinfo.userdata"          = base64gzip(templatefile("${var.role_path}/templates/userdata.tftpl", local.ns2.userdata))
    "guestinfo.userdata.encoding" = "gzip+base64"
  }
}
