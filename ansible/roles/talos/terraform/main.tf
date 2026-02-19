terraform {
  required_providers {
    vsphere = {
      source = "vmware/vsphere"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_username
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "resource_pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_content_library" "content_library" {
  name            = var.vsphere_content_library
  storage_backing = [data.vsphere_datastore.datastore.id]
}

resource "vsphere_content_library_item" "talos_ova" {
  name       = "talos-ova"
  file_url   = var.talos_ova_url
  library_id = resource.vsphere_content_library.content_library.id
}

resource "vsphere_virtual_machine" "control_plane" {
  count            = var.vm_config["control_plane"].count
  name             = "${var.vm_config["control_plane"].name_prefix}-${sum([count.index, 1])}"
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vsphere_folder
  num_cpus         = var.vm_config["control_plane"].num_cpus
  memory           = var.vm_config["control_plane"].memory_mb
  enable_disk_uuid = true

  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 300

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "disk0"
    thin_provisioned = true
    size             = var.vm_config["control_plane"].disk_gb
    io_reservation   = 1
  }

  clone {
    template_uuid = resource.vsphere_content_library_item.talos_ova.id
  }

  vapp {
    properties = {
      "talos.config" = base64encode(templatefile(
        "${path.module}/../talosconfig/controlplane.yaml",
        {
          ip_addr         = cidrhost(var.node_subnet_cidr, sum([count.index, 1]))
          netmask         = var.node_netmask
          vip             = var.control_plane_vip
          default_gateway = var.default_gateway
      }))
    }
  }
}

resource "vsphere_virtual_machine" "worker" {
  depends_on       = [vsphere_virtual_machine.control_plane]
  count            = var.vm_config["worker"].count
  name             = "${var.vm_config["worker"].name_prefix}-${sum([count.index, 1])}"
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vsphere_folder
  num_cpus         = var.vm_config["worker"].num_cpus
  memory           = var.vm_config["worker"].memory_mb
  enable_disk_uuid = true

  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 300

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "disk0"
    thin_provisioned = true
    size             = var.vm_config["worker"].disk_gb
    io_reservation   = 1
  }

  clone {
    template_uuid = resource.vsphere_content_library_item.talos_ova.id
  }

  vapp {
    properties = {
      "talos.config" = base64encode(templatefile(
        "${path.module}/../talosconfig/worker.yaml",
        {
          ip_addr         = cidrhost(var.node_subnet_cidr, sum([count.index, 1, var.vm_config["control_plane"].count]))
          netmask         = var.node_netmask
          default_gateway = var.default_gateway
      }))
    }
  }
}
