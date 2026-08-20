variable "proxmox_config" {
  type = object({
    node = string
  })
}

variable "iso_files" {
  type = map(object({
    url                = string
    file_name          = string
    datastore          = string
    checksum           = optional(string)
    checksum_algorithm = optional(string)
  }))
}