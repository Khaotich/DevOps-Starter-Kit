terraform {
  source = "../../modules//vm"
}

inputs = {
  service             = "forgejo"
  config_path_proxmox = "${get_original_terragrunt_dir()}/../../../../config/proxmox.yml"
  config_path_common  = "${get_original_terragrunt_dir()}/../../../../config/common.yml"
  config_path_service = "${get_original_terragrunt_dir()}/../../../../config/services/forgejo.yml"
}