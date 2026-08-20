terraform {
  source = "${get_repo_root()}//infra/01_provision/live/01_bootstrap"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repo_root   = get_repo_root()
  base_config = yamldecode(file("${local.repo_root}/config/common.yml"))

  vyos         = yamldecode(file("${local.repo_root}/config/services/vyos.yml"))
  net_services = yamldecode(file("${local.repo_root}/config/services/net_services.yml"))
  postgres     = yamldecode(file("${local.repo_root}/config/services/postgresql.yml"))
  forgejo      = yamldecode(file("${local.repo_root}/config/services/forgejo.yml"))
}

inputs = {
  vyos_config         = merge(local.base_config, local.vyos)
  net_services_config = merge(local.base_config, local.net_services)
  postgres_config     = merge(local.base_config, local.postgres)
  forgejo_config      = merge(local.base_config, local.forgejo)
  
  secrets = {
    vm_password = get_env("TF_VAR_vm_password", "")
    vm_keys     = [get_env("TF_VAR_vm_keys", "")]
  }
}