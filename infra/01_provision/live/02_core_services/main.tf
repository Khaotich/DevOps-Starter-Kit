variable "proxmox_config" { type = any }
variable "secrets_config" { type = any }

variable "postgres_config" { type = any }

module "postgres" {
  source = "../../modules/vm"

  vm_config      = var.postgres_config
  proxmox_config = var.proxmox_config
  secrets_config = var.secrets_config
}
