locals {
  capi-control-1 = {
    num_cpus     = 2
    memory_mb    = 4096
    disk_size_gb = 16
    metadata = {
      vm_name                   = "capi-control-1"
      internal_domain           = var.vm_domain
      vm_cidr                   = "10.0.50.61/24"
      vm_gateway                = "10.0.50.1"
      vm_dns                    = ["10.0.20.5", "10.0.20.6"]
      trustdinfo_token          = var.trustdinfo_token
      os_crt                    = var.os_crt
      os_key                    = var.os_key
      talos_cluster_name        = var.talos_cluster_name
      cluster_id                = var.cluster_id
      cluster_secret            = var.cluster_secret
      bootstrap_token           = var.bootstrap_token
      secretboxencryptionsecret = var.secretboxencryptionsecret
      k8s_crt                   = var.k8s_crt
      k8s_key                   = var.k8s_key
      k8saggregator_crt         = var.k8saggregator_crt
      k8saggregator_key         = var.k8saggregator_key
      k8sserviceaccount_key     = var.k8sserviceaccount_key
      etcd_crt                  = var.etcd_crt
      etcd_key                  = var.etcd_key
    }
  }
  capi-control-2 = {
    num_cpus     = 2
    memory_mb    = 4096
    disk_size_gb = 16
    metadata = {
      vm_name                   = "capi-control-2"
      internal_domain           = var.vm_domain
      vm_cidr                   = "10.0.50.62/24"
      vm_gateway                = "10.0.50.1"
      vm_dns                    = ["10.0.20.5", "10.0.20.6"]
      trustdinfo_token          = var.trustdinfo_token
      os_crt                    = var.os_crt
      os_key                    = var.os_key
      talos_cluster_name        = var.talos_cluster_name
      cluster_id                = var.cluster_id
      cluster_secret            = var.cluster_secret
      bootstrap_token           = var.bootstrap_token
      secretboxencryptionsecret = var.secretboxencryptionsecret
      k8s_crt                   = var.k8s_crt
      k8s_key                   = var.k8s_key
      k8saggregator_crt         = var.k8saggregator_crt
      k8saggregator_key         = var.k8saggregator_key
      k8sserviceaccount_key     = var.k8sserviceaccount_key
      etcd_crt                  = var.etcd_crt
      etcd_key                  = var.etcd_key
    }
  }
  capi-control-3 = {
    num_cpus     = 2
    memory_mb    = 4096
    disk_size_gb = 16
    metadata = {
      vm_name                   = "capi-control-3"
      internal_domain           = var.vm_domain
      vm_cidr                   = "10.0.50.63/24"
      vm_gateway                = "10.0.50.1"
      vm_dns                    = ["10.0.20.5", "10.0.20.6"]
      trustdinfo_token          = var.trustdinfo_token
      os_crt                    = var.os_crt
      os_key                    = var.os_key
      talos_cluster_name        = var.talos_cluster_name
      cluster_id                = var.cluster_id
      cluster_secret            = var.cluster_secret
      bootstrap_token           = var.bootstrap_token
      secretboxencryptionsecret = var.secretboxencryptionsecret
      k8s_crt                   = var.k8s_crt
      k8s_key                   = var.k8s_key
      k8saggregator_crt         = var.k8saggregator_crt
      k8saggregator_key         = var.k8saggregator_key
      k8sserviceaccount_key     = var.k8sserviceaccount_key
      etcd_crt                  = var.etcd_crt
      etcd_key                  = var.etcd_key
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

data "vsphere_datastore_cluster" "datastore_cluster" {
  name          = var.datastore_cluster_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "random_shuffle" "datastore" {
  input        = data.vsphere_datastore_cluster.datastore_cluster.datastores
  result_count = 1
}

data "vsphere_datastore" "datastore" {
  name          = resource.random_shuffle.datastore.result[0]
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster_host_group" "cluster_hosts" {
  name               = var.cluster_name
  compute_cluster_id = data.vsphere_compute_cluster.cluster.id
}

resource "random_shuffle" "host" {
  input        = data.vsphere_compute_cluster_host_group.cluster_hosts.host_system_ids
  result_count = 1
}

data "vsphere_resource_pool" "resource_pool" {
  name          = var.resource_pool_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}


data "vsphere_ovf_vm_template" "talos" {
  name              = "talos"
  disk_provisioning = "thin"
  resource_pool_id  = data.vsphere_resource_pool.resource_pool.id
  host_system_id    = resource.random_shuffle.host.result[0]
  datastore_id      = data.vsphere_datastore.datastore.id
  remote_ovf_url    = "https://factory.talos.dev/image/903b2da78f99adef03cbbd4df6714563823f63218508800751560d3bc3557e40/v1.10.5/vmware-amd64.ova"
  ovf_network_map = {
    "VM Network" : data.vsphere_network.network.id
  }
}

resource "vsphere_virtual_machine" "capi-control-1" {
  name             = local.capi-control-1.metadata.vm_name
  datacenter_id    = data.vsphere_datacenter.datacenter.id
  host_system_id   = resource.random_shuffle.host.result[0]
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.folder_name
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  num_cpus         = local.capi-control-1.num_cpus
  memory           = local.capi-control-1.memory_mb
  guest_id         = data.vsphere_ovf_vm_template.talos.guest_id
  scsi_type        = data.vsphere_ovf_vm_template.talos.scsi_type

  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.talos.ovf_network_map
    content {
      network_id = network_interface.value
    }
  }

  disk {
    label = "Hard Disk 1"
    size  = local.capi-control-1.disk_size_gb
  }
  enable_disk_uuid = true

  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0

  ovf_deploy {
    allow_unverified_ssl_cert = false
    remote_ovf_url            = data.vsphere_ovf_vm_template.talos.remote_ovf_url
    disk_provisioning         = data.vsphere_ovf_vm_template.talos.disk_provisioning
    ovf_network_map           = data.vsphere_ovf_vm_template.talos.ovf_network_map
  }
  extra_config = {
    "guestinfo.talos.config" = base64encode(templatefile("../talos/controlplane.yaml.tftpl", local.capi-control-1.metadata))
  }
}

resource "vsphere_virtual_machine" "capi-control-2" {
  name             = local.capi-control-2.metadata.vm_name
  datacenter_id    = data.vsphere_datacenter.datacenter.id
  host_system_id   = resource.random_shuffle.host.result[0]
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.folder_name
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  num_cpus         = local.capi-control-2.num_cpus
  memory           = local.capi-control-2.memory_mb
  guest_id         = data.vsphere_ovf_vm_template.talos.guest_id
  scsi_type        = data.vsphere_ovf_vm_template.talos.scsi_type

  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.talos.ovf_network_map
    content {
      network_id = network_interface.value
    }
  }

  disk {
    label = "Hard Disk 1"
    size  = local.capi-control-2.disk_size_gb
  }
  enable_disk_uuid = true

  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0

  ovf_deploy {
    allow_unverified_ssl_cert = false
    remote_ovf_url            = data.vsphere_ovf_vm_template.talos.remote_ovf_url
    disk_provisioning         = data.vsphere_ovf_vm_template.talos.disk_provisioning
    ovf_network_map           = data.vsphere_ovf_vm_template.talos.ovf_network_map
  }
  extra_config = {
    "guestinfo.talos.config" = base64encode(templatefile("../talos/controlplane.yaml.tftpl", local.capi-control-2.metadata))
  }
}

resource "vsphere_virtual_machine" "capi-control-3" {
  name             = local.capi-control-3.metadata.vm_name
  datacenter_id    = data.vsphere_datacenter.datacenter.id
  host_system_id   = resource.random_shuffle.host.result[0]
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.folder_name
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  num_cpus         = local.capi-control-3.num_cpus
  memory           = local.capi-control-3.memory_mb
  guest_id         = data.vsphere_ovf_vm_template.talos.guest_id
  scsi_type        = data.vsphere_ovf_vm_template.talos.scsi_type

  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.talos.ovf_network_map
    content {
      network_id = network_interface.value
    }
  }

  disk {
    label = "Hard Disk 1"
    size  = local.capi-control-3.disk_size_gb
  }
  enable_disk_uuid = true

  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0

  ovf_deploy {
    allow_unverified_ssl_cert = false
    remote_ovf_url            = data.vsphere_ovf_vm_template.talos.remote_ovf_url
    disk_provisioning         = data.vsphere_ovf_vm_template.talos.disk_provisioning
    ovf_network_map           = data.vsphere_ovf_vm_template.talos.ovf_network_map
  }
  extra_config = {
    "guestinfo.talos.config" = base64encode(templatefile("../talos/controlplane.yaml.tftpl", local.capi-control-3.metadata))
  }
}
