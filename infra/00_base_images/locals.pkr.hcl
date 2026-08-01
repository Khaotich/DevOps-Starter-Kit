locals {
  timestamp = formatdate("YYYY-MM-DD-hhmm", timestamp())
  
  proxmox_config = yamldecode(file("../config/proxmox.yml"))
  base_config = yamldecode(file("../config/common.yml"))
  distro_config = yamldecode(file("../config/base_images/${var.distro}.yml"))
  vm_config = merge(local.base_config, local.distro_config)
}