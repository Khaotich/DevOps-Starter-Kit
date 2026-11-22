variable "proxmox_config" { type = any }
variable "secrets_config" { type = any }

variable "postgres_config" { type = any }
variable "vault_config" { type = any }
variable "sso_config" { type = any }

module "postgres" {
  source = "../../modules/vm"

  vm_config      = var.postgres_config
  proxmox_config = var.proxmox_config
  secrets_config = var.secrets_config
}

module "vault" {
  source = "../../modules/vm"

  vm_config      = var.vault_config
  proxmox_config = var.proxmox_config
  secrets_config = var.secrets_config
}

module "sso" {
  source = "../../modules/vm"

  vm_config      = var.sso_config
  proxmox_config = var.proxmox_config
  secrets_config = var.secrets_config
}
