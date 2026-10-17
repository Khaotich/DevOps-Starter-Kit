terraform {
  source = "${get_repo_root()}//infra/01_provision/live/01_network"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repo_root   = get_repo_root()
  base_config = yamldecode(file("${local.repo_root}/config/common.yml"))

  vyos         = yamldecode(file("${local.repo_root}/config/services/vyos.yml"))
  dns          = yamldecode(file("${local.repo_root}/config/services/dns.yml"))
  haproxy      = yamldecode(file("${local.repo_root}/config/services/haproxy.yml"))
}

inputs = {
  vyos_config         = merge(local.base_config, local.vyos)
  dns_config          = merge(local.base_config, local.dns)
  haproxy_config      = merge(local.base_config, local.haproxy)
}