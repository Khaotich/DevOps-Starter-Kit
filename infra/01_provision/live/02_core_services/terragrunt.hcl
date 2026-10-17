terraform {
  source = "${get_repo_root()}//infra/01_provision/live/02_core_services"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repo_root   = get_repo_root()
  base_config = yamldecode(file("${local.repo_root}/config/common.yml"))

  postgres = yamldecode(file("${local.repo_root}/config/services/postgresql.yml"))
}

inputs = {
  postgres_config  = merge(local.base_config, local.postgres)
}