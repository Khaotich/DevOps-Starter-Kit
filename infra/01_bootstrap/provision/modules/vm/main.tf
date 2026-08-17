resource "proxmox_virtual_environment_vm" "vm" {
  name        = local.vm_config.hostname
  description = local.vm_config.description
  vm_id       = local.vm_config.id
  node_name   = local.proxmox_config.node
  on_boot     = local.vm_config.on_boot

  machine       = local.vm_config.machine
  scsi_hardware = local.vm_config.scsi_controller
  boot_order = ["${local.vm_config.disk_type}0", "net0"]
  operating_system {
    type = local.vm_config.operating_system
  }
  
  bios = local.vm_config.bios
  efi_disk {
    datastore_id      = local.vm_config.disk_storage_pool
    type              = local.vm_config.efi_disk_type
    pre_enrolled_keys = local.vm_config.efi_disk_pre_enrolled_key
  }

  tpm_state {
    datastore_id = local.vm_config.disk_storage_pool
    version      = local.vm_config.tpm_version
  }

  agent {
    enabled =  local.vm_config.qemu_agent
  }

  cpu {
    cores = local.vm_config.cores
    type  = local.vm_config.cpu_type
  }

  memory {
    dedicated = local.vm_config.ram_memory
    floating  = local.vm_config.ram_memory
  }

  disk {
    datastore_id = local.vm_config.disk_storage_pool
    interface    = "${local.vm_config.disk_type}0"
    size         = local.vm_config.disk_size_gb
    file_id      = "local:import/${local.vm_config.qcow2_file}.qcow2"
  }

  dynamic "disk" {
    for_each = try(local.vm_config.disks, [])
    content {
      datastore_id = local.vm_config.disk_storage_pool
      interface    = "${local.vm_config.disk_type}${disk.key + 1}"
      size         = disk.value.size_gb
    }
  }

  dynamic "network_device" {
    for_each = try(local.vm_config.network_bridges, [])
    content {
      bridge = network_device.value.bridge
    }
  }

  initialization {
    datastore_id = local.vm_config.disk_storage_pool
    interface    = "ide2"
    upgrade      = true

    user_account {
      username = local.vm_config.user
      password = var.vm_password
      keys = var.vm_keys
    }
    
    ip_config {
      ipv4 {
        address = "${local.vm_config.ip}/${local.vm_config.cidr}"
        gateway = local.vm_config.gateway
      }
    }

    dns {
      servers = local.vm_config.dns_servers
      domain  = local.vm_config.dns_domain
    }
  }
}
