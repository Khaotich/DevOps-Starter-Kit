variable "proxmox_config" { type = any }
variable "bridges"        { type = any }
variable "iso_files"      { type = any }

module "network_bridges" {
  source = "../../modules/network_bridge"
  proxmox_config = var.proxmox_config
  bridges        = var.bridges
}

module "iso_images" {
  source = "../../modules/iso"
  proxmox_config = var.proxmox_config
  iso_files      = var.iso_files
}