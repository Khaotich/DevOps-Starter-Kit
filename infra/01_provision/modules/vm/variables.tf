variable "vm_config" {
  type        = any
}

variable "proxmox_config" {
  type        = any
}

variable "vm_password" {
  type      = string
  default   = null
  sensitive = true
}

variable "vm_keys" {
  type    = list(string)
  default = []
}