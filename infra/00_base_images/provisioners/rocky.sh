#!/bin/bash

# Exit immediately if any command fails
set -e

echo "==> 1. System Updates and Repository Setup"
# Upgrade system packages excluding kernel and firmware for base image stability
dnf upgrade -y --exclude=kernel*,linux-firmware
# Install EPEL repository first (required as a dependency for fail2ban)
dnf install -y epel-release

echo "==> 2. Bulk Package Installation"
# Grouping installations minimizes DNF metadata operations and speeds up the build
dnf install -y cloud-init cloud-utils-growpart firewalld fail2ban dnf-automatic wget nano python3-pip python3-devel

echo "==> 3. File System and Kernel Hardening"
cat << 'EOF' > /etc/sysctl.d/20-quiet-printk.conf
kernel.printk = 3 4 1 3
EOF

# Secure /tmp and /dev/shm mounts in /etc/fstab with strict execution permissions
# if ! grep -q "/tmp" /etc/fstab; then
#     echo "tmpfs /tmp tmpfs defaults,noexec,nosuid,nodev,size=1G 0 0" >> /etc/fstab
# fi
if ! grep -q "/dev/shm" /etc/fstab; then
    echo "tmpfs /dev/shm tmpfs defaults,nodev,nosuid,noexec 0 0" >> /etc/fstab
fi

# Apply hardened sysctl configuration for network protection
cat << 'EOF' > /etc/sysctl.d/99-hardened.conf
# IP Spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP broadcast requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Disable ICMP redirect acceptance
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Disable Source Routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
EOF
sysctl --system

echo "==> 4. Application Configuration (DNF Automatic & Fail2Ban)"
# Configure dnf-automatic to automatically download and apply security updates
sed -i 's/upgrade_type =.*/upgrade_type = default/' /etc/dnf/automatic.conf
sed -i 's/apply_updates =.*/apply_updates = yes/' /etc/dnf/automatic.conf

# Deploy local fail2ban jail configuration for SSH protection
cat << 'EOF' > /etc/fail2ban/jail.local
[sshd]
enabled = true
port = 22
maxretry = 5
bantime = 3600
EOF

echo "==> 5. User Account and SSH Service Hardening"
# Lock the root user account to disable direct password authentication
passwd -l root

# Deploy strict SSH daemon configurations (Removed 'packer' from AllowUsers, only 'admin' remains)
cat << 'EOF' > /etc/ssh/sshd_config.d/99-hardened.conf
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
ClientAliveInterval 300
LoginGraceTime 30
X11Forwarding no
AllowTcpForwarding no
EOF
chmod 600 /etc/ssh/sshd_config.d/99-hardened.conf

echo "==> 6. Enabling and Starting Services"
# Enable Cloud-Init provisioning services
systemctl enable cloud-init-local.service
systemctl enable cloud-init.service
systemctl enable cloud-config.service
systemctl enable cloud-final.service

# Start and configure Firewalld FIRST so Fail2ban can latch onto its zones cleanly
systemctl enable --now firewalld
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

# Start security automation services
systemctl enable --now fail2ban
systemctl enable --now dnf-automatic.timer

# Reload SSH configuration safely without dropping the active Packer session channel
systemctl reload sshd

echo "==> 7. Final Cleanup and Golden Template Sanitization"
# Remove orphaned packages and purge package manager caching layers
dnf remove --oldinstallonly -y
dnf autoremove -y
dnf clean all

# Truncate logs to prevent cloning historical build metadata into instances
if [ -f /var/log/audit/audit.log ]; then
    > /var/log/audit/audit.log
fi
restorecon -fv /var/log/audit/audit.log || true
truncate -s 0 /var/log/wtmp || true
truncate -s 0 /var/log/lastlog || true

# Remove unique SSH host keys so Cloud-Init generates fresh, unique keys on first boot
rm -f /etc/ssh/ssh_host_*

# Reset systemd machine-id to prevent network/DHCP lease duplication conflicts across clones
truncate -s 0 /etc/machine-id

# Clear local temporary cache files
rm -f /etc/rc.d/rc.local
rm -rf /tmp/*
rm -rf /var/tmp/*

# Sanitize Cloud-Init logs and operational status for a clean boot cycle
cloud-init clean --logs

fixfiles -F relabel || true

echo "==> Provisioning successfully completed in optimal order!"
