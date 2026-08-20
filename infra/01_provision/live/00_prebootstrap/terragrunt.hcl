terraform {
  source = "${get_repo_root()}//infra/01_provision/live/00_prebootstrap"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repo_root   = get_repo_root()
  iso_config = yamldecode(file("${local.repo_root}/config/iso.yml"))
  network_config = yamldecode(file("${local.repo_root}/config/network.yml"))
}

inputs = {
  iso_files = local.iso_config.iso_images
  bridges   = local.network_config.bridges
}