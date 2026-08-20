locals {
  repo_root      = get_repo_root()
  proxmox_config = yamldecode(file("${local.repo_root}/config/proxmox.yml"))
  base_config    = yamldecode(file("${local.repo_root}/config/common.yml"))
}

inputs = {
  proxmox_config = local.proxmox_config
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
  api_token = "${local.proxmox_config.user}@pam!${local.proxmox_config.token_id}=${get_env("TF_VAR_proxmox_token_secret", "")}"
  insecure  = true

  ssh {
    agent    = true
    username = "${local.proxmox_config.user}"
    password = "${get_env("TF_VAR_proxmox_password", "")}"
  }
}
EOF
}