source "proxmox-iso" "base-image" {
  proxmox_url = "https://${local.proxmox_config.ip}:${local.proxmox_config.port}/api2/json"
  username = "${local.proxmox_config.user}@${local.proxmox_config.realm}!${local.proxmox_config.token_id}"
  token = local.secrets_config.proxmox_token_secret
  insecure_skip_tls_verify = local.proxmox_config.insecure_skip_tls_verify
  node = local.proxmox_config.node

  vm_id = local.vm_config.id
  vm_name = local.vm_config.hostname

  template_name = local.vm_config.template_name
  template_description = local.vm_config.template_description
  
  cloud_init = local.vm_config.cloud_init
  cloud_init_storage_pool = local.vm_config.disk_storage_pool
  qemu_agent = local.vm_config.qemu_agent

  additional_iso_files {
      cd_content = {"/${local.vm_config.cfg_file}.cfg" = templatefile("${abspath(path.cwd)}/templates/cfg/${local.vm_config.cfg_file}.pkrtpl.hcl", { vm_config = local.vm_config, user_password = local.secrets_config.vm_ssh_password_hash, ssh_public_key = local.secrets_config.vm_ssh_public_key })}
      cd_label = local.vm_config.cd_label
      iso_storage_pool = local.vm_config.iso_storage_pool
      type = local.vm_config.disk_type
  }

  scsi_controller = local.vm_config.scsi_controller

  boot_iso {
    iso_file = "${local.vm_config.iso_storage_pool}:iso/${local.vm_config.iso_file}.iso"
    unmount = local.vm_config.unmount_iso
    type = local.vm_config.disk_type
  }

  bios = local.vm_config.bios
  boot = local.vm_config.boot
  boot_command = compact(split("\n", replace(templatefile("${abspath(path.cwd)}/templates/boot_command/${local.vm_config.boot_file}.pkrtpl.hcl", { vm_config = local.vm_config, user_password = local.secrets_config.vm_ssh_password, ssh_public_key =split(" ", local.secrets_config.vm_ssh_public_key)[1] }), "\r", "")))
  boot_wait = local.vm_config.boot_wait

  efi_config {
    efi_storage_pool = local.vm_config.disk_storage_pool
    efi_type = local.vm_config.efi_type
    pre_enrolled_keys = false
  }

  ssh_timeout = local.vm_config.ssh_timeout
  ssh_handshake_attempts = local.vm_config.ssh_handshake_attempts
  ssh_username = local.vm_config.ssh_username
  ssh_password = local.secrets_config.vm_ssh_password
  
  cpu_type = local.vm_config.cpu_type
  sockets = local.vm_config.sockets
  cores = local.vm_config.cores
  memory = local.vm_config.ram_memory
  ballooning_minimum = local.vm_config.ram_memory

  disks {
    disk_size = local.vm_config.disk_size
    format = local.vm_config.disk_format
    storage_pool = local.vm_config.disk_storage_pool
    cache_mode = local.vm_config.disk_cache_mode
    discard = local.vm_config.disk_discard
    type = local.vm_config.disk_type
  }
  
  network_adapters {
    bridge = local.vm_config.network_bridge
    model = local.vm_config.network_model
    firewall = local.vm_config.network_firewall
  }
}
