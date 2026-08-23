build {

  name = local.vm_config.name

  sources = [
    "source.proxmox-iso.base-image"
  ]

  provisioner "shell" {
      execute_command = local.vm_config.provisioner_command
      script = "provisioners/${local.vm_config.provisioner_file}.sh"      
  }

  post-processor "shell-local" {
    inline = [
      "ssh -i ${local.proxmox_config.ssh_private_file_path} ${local.proxmox_config.user}@${local.proxmox_config.ip} '",
      "  DISK_RAW=$(sudo qm config ${local.vm_config.id} | awk \"/^${local.vm_config.disk_type}0:/ {print \\$2}\" | cut -d, -f1) && \\",
      "  DISK_VOL=$(echo $${DISK_RAW} | cut -d: -f2) && \\",
      "  sudo qemu-img convert -O qcow2 ${local.proxmox_config.disks_directory}/$${DISK_VOL} ${local.proxmox_config.qcow2_directory}/${local.vm_config.name}-${local.timestamp}.qcow2 && \\",
      "  sudo qemu-img convert -O qcow2 ${local.proxmox_config.disks_directory}/$${DISK_VOL} ${local.proxmox_config.qcow2_directory}/${local.vm_config.name}-stable.qcow2",
      "'",
      "ssh -i ${local.proxmox_config.ssh_private_file_path} ${local.proxmox_config.user}@${local.proxmox_config.ip} 'sudo qm destroy ${local.vm_config.id}'",
      "ssh -i ${local.proxmox_config.ssh_private_file_path} ${local.proxmox_config.user}@${local.proxmox_config.ip} 'sudo rm -f ${local.proxmox_config.iso_directory}/packer*'"
    ]
  }
}
