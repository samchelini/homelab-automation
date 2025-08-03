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

variable "trustdinfo_token" {
  type      = string
  sensitive = true
}

variable "os_crt" {
  type = string
}

variable "os_key" {
  type      = string
  sensitive = true
}

variable "talos_cluster_name" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "cluster_secret" {
  type      = string
  sensitive = true
}

variable "bootstrap_token" {
  type      = string
  sensitive = true
}

variable "secretboxencryptionsecret" {
  type      = string
  sensitive = true
}

variable "k8s_crt" {
  type = string
}

variable "k8s_key" {
  type      = string
  sensitive = true
}

variable "k8saggregator_crt" {
  type = string
}

variable "k8saggregator_key" {
  type      = string
  sensitive = true
}

variable "k8sserviceaccount_key" {
  type      = string
  sensitive = true
}

variable "etcd_crt" {
  type = string
}

variable "etcd_key" {
  type      = string
  sensitive = true
}
