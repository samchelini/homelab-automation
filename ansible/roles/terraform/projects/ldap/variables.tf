variable "vsphere_user" {
  type = string
}

variable "vsphere_password" {
  type      = string
  sensitive = true
}

variable "vsphere_server" {
  type = string
}

variable "datacenter_name" {
  type = string
}

variable "datastore_cluster_name" {
  type = string
}

variable "template_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "resource_pool_name" {
  type = string
}

variable "network_name" {
  type = string
}

variable "folder_name" {
  type = string
}

variable "vm_domain" {
  type = string
}

variable "guest_id" {
  type = string
}

variable "ansible_public_ssh_key" {
  type = string
}

variable "role_path" {
  type = string
}
