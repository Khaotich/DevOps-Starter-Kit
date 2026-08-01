variable "distro" {
  type      = string
  default   = ""
}

variable "proxmox_token_secret" {
  type      = string
  sensitive = true
}

variable "vm_ssh_password" {
  type      = string
  sensitive = true
}

variable "vm_ssh_password_hash" {
  type      = string
  sensitive = true
}

variable "vm_ssh_public_key" {
  type      = string
  sensitive = true
}
