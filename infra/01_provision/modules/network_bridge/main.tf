resource "proxmox_network_linux_bridge" "bridge" {
  for_each = var.bridges

  node_name = var.proxmox_config.node
  name      = each.key

  comment    = each.value.comment
  address    = each.value.address
  ports      = each.value.ports
  autostart  = each.value.autostart
  vlan_aware = each.value.vlan_aware
}