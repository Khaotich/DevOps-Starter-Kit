provider "proxmox" {
  endpoint = "https://${local.proxmox_config.ip}:${local.proxmox_config.port}/"
  api_token = "${local.proxmox_config.user}@pam!${local.proxmox_config.token_id}=${var.proxmox_token_secret}"
  insecure  = true
  
  ssh {
    agent = true
    username = local.proxmox_config.user
    password = var.proxmox_password
  }
}
