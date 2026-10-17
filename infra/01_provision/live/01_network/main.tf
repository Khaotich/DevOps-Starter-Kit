variable "proxmox_config" { type = any }
variable "secrets_config" { type = any }

variable "vyos_config"     { type = any }
variable "dns_config"      { type = any }
variable "haproxy_config"  { type = any }

module "vyos" {
  source = "../../modules/vm"

  vm_config      = var.vyos_config
  proxmox_config = var.proxmox_config
  secrets_config = var.secrets_config
}

module "dns" {
  source = "../../modules/vm"

  vm_config      = var.dns_config
  proxmox_config = var.proxmox_config
  secrets_config = var.secrets_config
}

module "haproxy" {
  source = "../../modules/vm"

  vm_config      = var.haproxy_config
  proxmox_config = var.proxmox_config
  secrets_config = var.secrets_config
}
