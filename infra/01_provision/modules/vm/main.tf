resource "proxmox_virtual_environment_vm" "vm" {
  name        = var.vm_config.hostname
  description = var.vm_config.description
  vm_id       = var.vm_config.id
  node_name   = var.proxmox_config.node
  on_boot     = var.vm_config.on_boot

  machine       = var.vm_config.machine
  scsi_hardware = var.vm_config.scsi_controller
  boot_order = ["${var.vm_config.disk_type}0", "net0"]
  operating_system {
    type = var.vm_config.operating_system
  } 
  
  bios = var.vm_config.bios
  efi_disk {
    datastore_id      = var.vm_config.disk_storage_pool
    type              = var.vm_config.efi_disk_type
    pre_enrolled_keys = var.vm_config.efi_disk_pre_enrolled_key
  }

  tpm_state {
    datastore_id = var.vm_config.disk_storage_pool
    version      = var.vm_config.tpm_version
  }

  agent {
    enabled =  var.vm_config.qemu_agent
  }

  cpu {
    cores = var.vm_config.cores
    type  = var.vm_config.cpu_type
  }

  memory {
    dedicated = var.vm_config.ram_memory
    floating  = var.vm_config.ram_memory
  }

  disk {
    datastore_id = var.vm_config.disk_storage_pool
    interface    = "${var.vm_config.disk_type}0"
    size         = var.vm_config.disk_size_gb
    file_id      = "local:import/${var.vm_config.qcow2_file}.qcow2"
  }

  dynamic "disk" {
    for_each = try(var.vm_config.disks, [])
    content {
      datastore_id = var.vm_config.disk_storage_pool
      interface    = "${var.vm_config.disk_type}${disk.key + 1}"
      size         = disk.value.size_gb
    }
  }

  dynamic "network_device" {
    for_each = try(var.vm_config.network_bridges, [])
    content {
      bridge = network_device.value.bridge
    }
  }

  initialization {
    datastore_id = var.vm_config.disk_storage_pool
    interface    = "ide2"
    upgrade      = true

    user_account {
      username = var.vm_config.user
      password = var.vm_password
      keys     = [for k in var.vm_keys : trimspace(k)]
    }
    
    ip_config {
      ipv4 {
        address = "${var.vm_config.ip}/${var.vm_config.cidr}"
        gateway = var.vm_config.gateway
      }
    }

    dns {
      servers = var.vm_config.dns_servers
      domain  = var.vm_config.dns_domain
    }
  }
}
