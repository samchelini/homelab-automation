packer {
  required_plugins {
    vsphere = {
      version = "~> 1"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

locals {
  debian_version = "13.1.0"
  debian_os_type = "debian13_64Guest"

  # generic username/hostname/domain
  # these will get replaced by cloud-init configs
  vm_username = "packer"
  vm_hostname = "packer-template"
  vm_domain   = "localdomain"

  # essential packages for cloud-init
  vm_packages = "openssh-server openresolv open-vm-tools cloud-init"

  # unmount preseed cdrom
  early_command = "umount /mnt; echo 1 > /sys/block/sr1/device/delete"

  late_commands = [
    # reset network config (will use cloud-init to configure it)
    "echo \"source /etc/network/interfaces.d/*\" > /target/etc/network/interfaces",
    # disable ipv6
    "echo \"net.ipv6.conf.all.disable_ipv6 = 1\" >> /target/etc/sysctl.d/local.conf"
  ]

  # variables to use in preseed template
  preseed_cfg = templatefile("./preseed.cfg.pkrtpl.hcl", {
    vm_ip         = var.vm_ip
    vm_netmask    = var.vm_netmask
    vm_gateway    = var.vm_gateway
    vm_dns        = var.vm_dns
    vm_username   = local.vm_username
    vm_hostname   = local.vm_hostname
    vm_domain     = local.vm_domain
    vm_packages   = local.vm_packages
    early_command = local.early_command
    late_command  = join("; ", local.late_commands)
  })
}

source "vsphere-iso" "debian" {
  # iso configuration
  iso_url      = "https://cdimage.debian.org/debian-cd/${local.debian_version}/amd64/iso-cd/debian-${local.debian_version}-amd64-netinst.iso"
  iso_checksum = "file:https://cdimage.debian.org/debian-cd/${local.debian_version}/amd64/iso-cd/SHA512SUMS"

  # vcenter connection configuration
  vcenter_server      = var.vcenter_url
  username            = var.vcenter_username
  password            = var.vcenter_password
  insecure_connection = true

  # location configuration
  vm_name   = "debian${local.debian_version}_cloud-init_template"
  folder    = var.vm_folder
  cluster   = var.vcenter_cluster
  host      = var.vcenter_host
  datastore = var.vcenter_datastore

  # hardware configuration
  guest_os_type = local.debian_os_type
  CPUs          = 1
  RAM           = 2048
  network_adapters {
    network      = var.vm_network
    network_card = "vmxnet3"
  }
  remove_network_adapter = true
  storage {
    disk_size             = var.vm_disk_mb
    disk_thin_provisioned = true
  }

  # mount preseed template on cdrom
  cd_content = {
    "preseed.cfg" = local.preseed_cfg
  }

  # boot configuration
  boot_command = [
    "<esc>",
    "auto preseed/file=/preseed.cfg", "<enter><wait30s>",

    # mount preseed cdrom and retry
    "<leftAltOn><f2><leftAltOff>", "<enter><wait>",
    "mount /dev/sr1 /mnt", "<enter>",
    "cp /mnt/preseed.cfg /", "<enter>",
    "<leftAltOn><f1><leftAltOff>", "<enter><wait><enter>",
    "<down><down><down><down><enter>"
  ]

  # not using any provisioners, so disable communicator and increase timeout
  communicator     = "none"
  shutdown_timeout = "15m"

  convert_to_template = true
}

build {
  sources = ["source.vsphere-iso.debian"]
}
