locals {
  repo_root      = get_repo_root()
  secrets_config = yamldecode(sops_decrypt_file("${get_repo_root()}/secrets/secrets.enc.yml"))
  proxmox_config = yamldecode(file("${local.repo_root}/config/proxmox.yml"))
  base_config    = yamldecode(file("${local.repo_root}/config/common.yml"))
}

inputs = {
  proxmox_config = local.proxmox_config
  secrets_config = local.secrets_config
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.111.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.4.1"
    }
  }
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
provider "proxmox" {
  endpoint  = "https://${local.proxmox_config.ip}:${local.proxmox_config.port}/"
  api_token = "${local.proxmox_config.user}@${local.proxmox_config.realm}!${local.proxmox_config.token_id}=${local.secrets_config.proxmox_token_secret}"
  insecure  = true

  ssh {
    agent    = true
    username = "${local.proxmox_config.user}"
    password = "${local.secrets_config.proxmox_password}"
  }
}
EOF
}