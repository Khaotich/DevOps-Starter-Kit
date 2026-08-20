variable "proxmox_config" {
  type = object({
    node = string
  })
}

variable "bridges" {
  type = map(object({
    comment    = optional(string)
    address    = optional(string)
    ports      = optional(list(string), [])
    autostart  = optional(bool, true)
    vlan_aware = optional(bool, false)
  }))
}