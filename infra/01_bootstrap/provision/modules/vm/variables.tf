variable "service" {
  type      = string
  default   = ""
}

variable "proxmox_password" {
  type        = string
  default     = null
  sensitive   = true
}

variable "proxmox_token_secret" {
  type        = string
  default     = null
  sensitive   = true
}

variable "vm_password" {
  type        = string
  sensitive   = true
}

variable "vm_keys" {
  type        = list(string)
  default     = []
}

variable "config_path_proxmox" {
  type        = string
}

variable "config_path_common" {
  type        = string
}

variable "config_path_service" {
  type        = string
}