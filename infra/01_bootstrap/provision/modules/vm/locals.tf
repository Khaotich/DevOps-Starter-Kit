locals {  
  proxmox_config = yamldecode(file(var.config_path_proxmox))
  base_config    = yamldecode(file(var.config_path_common))
  service_config = yamldecode(file(var.config_path_service))
  vm_config      = merge(local.base_config, local.service_config)
}