resource "proxmox_download_file" "iso" {
  for_each = var.iso_files

  node_name    = var.proxmox_config.node
  datastore_id = each.value.datastore
  content_type = "iso"

  url       = each.value.url
  file_name = each.value.file_name

  checksum           = each.value.checksum
  checksum_algorithm = each.value.checksum_algorithm

  upload_timeout = 1200
}