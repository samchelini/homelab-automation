variable "vsphere_username" {
  type = string
}

variable "vsphere_password" {
  type      = string
  sensitive = true
}

variable "vsphere_server" {
  type = string
}

variable "vsphere_datacenter" {
  type = string
}

variable "vsphere_datastore" {
  type = string
}

variable "vsphere_cluster" {
  type = string
}

variable "vsphere_resource_pool" {
  type = string
}

variable "vsphere_network" {
  type = string
}

variable "vsphere_content_library" {
  type = string
}

variable "talos_ova_url" {
  type = string
}

variable "vsphere_folder" {
  type = string
}

variable "control_plane_vip" {
  type = string
}

variable "node_subnet_cidr" {
  type = string
}

variable "node_netmask" {
  type = string
}

variable "default_gateway" {
  type = string
}

variable "vm_config" {
  type = map(object({
    count       = number
    name_prefix = string
    num_cpus    = number
    memory_mb   = number
    disk_gb     = number
  }))
  default = {
    control_plane = {
      count       = 1
      name_prefix = "talos-control"
      num_cpus    = 2
      memory_mb   = 2048
      disk_gb     = 16
    }
    worker = {
      count       = 1
      name_prefix = "talos-worker"
      num_cpus    = 2
      memory_mb   = 2048
      disk_gb     = 16
    }
  }
}
