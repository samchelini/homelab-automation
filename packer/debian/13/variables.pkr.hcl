variable "vcenter_url" {
  type = string
}

variable "vcenter_username" {
  type = string
}

variable "vcenter_password" {
  type      = string
  sensitive = true
}

variable "vcenter_cluster" {
  type = string
}

variable "vcenter_host" {
  type = string
}

variable "vcenter_datastore" {
  type = string
}

variable "vm_network" {
  type = string
}

variable "vm_folder" {
  type = string
}

variable "vm_disk_mb" {
  type = number
}

variable "vm_ip" {
  type = string
}

variable "vm_netmask" {
  type = string
}

variable "vm_gateway" {
  type = string
}

variable "vm_dns" {
  type = string
}
