#!/bin/vbash

configure

# =====================================================
# INTERFACES CONFIGURATION
# =====================================================
# WAN interface - connected to upstream router / internet
set interfaces ethernet eth0 address '192.168.0.20/24'
set interfaces ethernet eth0 description 'WAN'

# LAN interface - internal private network
set interfaces ethernet eth1 address '10.0.0.1/24'
set interfaces ethernet eth1 description 'LAN'


# =====================================================
# SYSTEM DNS CONFIGURATION (VyOS itself)
# =====================================================
# Used by router for outbound DNS queries (not clients)
set system name-server '1.1.1.1'
set system name-server '8.8.8.8'


# =====================================================
# DNS FORWARDING (for LAN clients)
# =====================================================
# Router acts as DNS resolver for internal network
set service dns forwarding cache-size '150'
set service dns forwarding listen-address '10.0.0.1'
set service dns forwarding allow-from '10.0.0.0/24'


# =====================================================
# NAT (INTERNET ACCESS FOR LAN)
# =====================================================
# Translates internal LAN addresses to WAN interface IP
set nat source rule 100 outbound-interface 'eth0'
set nat source rule 100 source address '10.0.0.0/24'
set nat source rule 100 translation address masquerade


# =====================================================
# ROUTING
# =====================================================
# Default route to upstream gateway (router)
set protocols static route 0.0.0.0/0 next-hop '192.168.0.1'


# =====================================================
# SERVICES
# =====================================================
# SSH management access to router
set service ssh port '22'


# =====================================================
# DHCP SERVER (LAN CLIENTS)
# =====================================================
# Provides IP configuration to internal devices
set service dhcp-server shared-network-name LAN subnet 10.0.0.0/24 option default-router '10.0.0.1'
set service dhcp-server shared-network-name LAN subnet 10.0.0.0/24 option name-server '10.0.0.1'
set service dhcp-server shared-network-name LAN subnet 10.0.0.0/24 option domain-name 'local'
set service dhcp-server shared-network-name LAN subnet 10.0.0.0/24 lease '86400'
set service dhcp-server shared-network-name LAN subnet 10.0.0.0/24 range 0 start '10.0.0.10'
set service dhcp-server shared-network-name LAN subnet 10.0.0.0/24 range 0 stop '10.0.0.220'
set service dhcp-server shared-network-name LAN subnet 10.0.0.0/24 subnet-id '1'

# =====================================================
# FIREWALL OVERVIEW
# =====================================================
# This firewall protects:
# - LAN (10.0.0.0/24) from WAN access
# - VyOS router itself from external access
# - allows only stateful return traffic
# - allows controlled management access (SSH, DNS, ICMP)
#
# Traffic model:
# LAN -> WAN  = allowed (NAT)
# WAN -> LAN  = blocked
# WAN -> VyOS = blocked (except SSH/ping rules)
# =====================================================


# =====================================================
# INTERFACE GROUPS (used for simplified rule matching)
# =====================================================
# WAN = external network (internet side)
# LAN = internal trusted network
# =====================================================
set firewall group interface-group WAN interface eth0
set firewall group interface-group LAN interface eth1


# =====================================================
# INTERNAL NETWORK DEFINITION
# =====================================================
# Used to define protected network behind firewall
# =====================================================
set firewall group network-group NET-INSIDE-v4 network '192.168.44.0/24'


# =====================================================
# STATEFUL FIREWALL ENGINE
# =====================================================
# Allow return traffic and drop invalid packets globally
# =====================================================
set firewall global-options state-policy established action accept
set firewall global-options state-policy related action accept
set firewall global-options state-policy invalid action drop


# =====================================================
# WAN -> LAN PROTECTION (FORWARD TRAFFIC)
# =====================================================
# Blocks all attempts from WAN to access internal network
# =====================================================
set firewall ipv4 name OUTSIDE-IN default-action 'drop'

set firewall ipv4 forward filter rule 100 action jump
set firewall ipv4 forward filter rule 100 jump-target OUTSIDE-IN
set firewall ipv4 forward filter rule 100 inbound-interface group WAN
set firewall ipv4 forward filter rule 100 destination group network-group NET-INSIDE-v4


# =====================================================
# ROUTER PROTECTION (INPUT TRAFFIC)
# =====================================================
# Default deny policy for all traffic targeting VyOS itself
# =====================================================
set firewall ipv4 input filter default-action 'drop'


# =====================================================
# SSH MANAGEMENT ACCESS CONTROL
# =====================================================
# Allows SSH only from LAN, restricts WAN with rate-limit
# =====================================================
set firewall ipv4 name VyOS_MANAGEMENT default-action 'return'

set firewall ipv4 input filter rule 20 action jump
set firewall ipv4 input filter rule 20 jump-target VyOS_MANAGEMENT
set firewall ipv4 input filter rule 20 destination port 22
set firewall ipv4 input filter rule 20 protocol tcp

set firewall ipv4 name VyOS_MANAGEMENT rule 15 action 'accept'
set firewall ipv4 name VyOS_MANAGEMENT rule 15 inbound-interface group 'LAN'

set firewall ipv4 name VyOS_MANAGEMENT rule 20 action 'drop'
set firewall ipv4 name VyOS_MANAGEMENT rule 20 recent count 4
set firewall ipv4 name VyOS_MANAGEMENT rule 20 recent time minute
set firewall ipv4 name VyOS_MANAGEMENT rule 20 state new
set firewall ipv4 name VyOS_MANAGEMENT rule 20 inbound-interface group 'WAN'

set firewall ipv4 name VyOS_MANAGEMENT rule 21 action 'accept'
set firewall ipv4 name VyOS_MANAGEMENT rule 21 state new
set firewall ipv4 name VyOS_MANAGEMENT rule 21 inbound-interface group 'WAN'


# =====================================================
# BASIC SERVICES ACCESS
# =====================================================

# Allow ICMP (ping) for diagnostics
set firewall ipv4 input filter rule 30 action 'accept'
set firewall ipv4 input filter rule 30 icmp type-name 'echo-request'
set firewall ipv4 input filter rule 30 protocol 'icmp'
set firewall ipv4 input filter rule 30 state new

# Allow DNS queries from LAN to router DNS forwarder
set firewall ipv4 input filter rule 40 action 'accept'
set firewall ipv4 input filter rule 40 destination port '53'
set firewall ipv4 input filter rule 40 protocol 'tcp_udp'
set firewall ipv4 input filter rule 40 source group network-group NET-INSIDE-v4

# Allow loopback traffic (local system communication)
set firewall ipv4 input filter rule 50 action 'accept'
set firewall ipv4 input filter rule 50 source address 127.0.0.0/8

commit
save
exit
