variable "proxmox_config" { type = any }
variable "secrets"        { type = any }

variable "vyos_config"         { type = any }
variable "net_services_config" { type = any }
variable "postgres_config"     { type = any }
variable "forgejo_config"      { type = any }

module "vyos" {
  source = "../../modules/vm"

  vm_config      = var.vyos_config
  proxmox_config = var.proxmox_config
  vm_password    = var.secrets.vm_password
  vm_keys        = var.secrets.vm_keys
}

module "net_services" {
  source = "../../modules/vm"

  vm_config      = var.net_services_config
  proxmox_config = var.proxmox_config
  vm_password    = var.secrets.vm_password
  vm_keys        = var.secrets.vm_keys
}

module "forgejo" {
  source = "../../modules/vm"

  vm_config      = var.forgejo_config
  proxmox_config = var.proxmox_config
  vm_password    = var.secrets.vm_password
  vm_keys        = var.secrets.vm_keys
}

module "postgres" {
  source = "../../modules/vm"

  vm_config      = var.postgres_config
  proxmox_config = var.proxmox_config
  vm_password    = var.secrets.vm_password
  vm_keys        = var.secrets.vm_keys
}