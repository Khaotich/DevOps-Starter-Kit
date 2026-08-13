# Installation mode
cdrom
text

eula --agreed

# Locale
lang en_US.UTF-8
keyboard us
timezone Europe/Warsaw --utc

# Network
network --bootproto=dhcp --device=link --activate --hostname=packer-template

# Auth
rootpw --lock
user --name=${user_name} --password=${user_password} --iscrypted --groups=wheel
sshkey --username=${user_name} "${ssh_public_key} ${user_name}@lan"

# Security
firewall --enable
selinux --enforcing

# Bootloader
bootloader --append="console=ttyS0,115200n8 console=tty0"

# Disk
zerombr
clearpart --all --initlabel
autopart --type=lvm

# System
skipx
firstboot --disable

services --enabled=sshd,chronyd,NetworkManager

# Packages
%packages --ignoremissing
@^minimal-environment
sudo
curl
tar
zip
openssh-server
python3
-iwl*firmware
%end

# Disable kdump
%addon com_redhat_kdump --disable
%end

#POST
%post --log=/root/ks-post.log

echo "==> Configure sudo"
echo "${user_name} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${user_name}
chmod 440 /etc/sudoers.d/${user_name}

echo "==> SSH config for Packer"
sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

mkdir -p /etc/ssh/sshd_config.d
echo "PermitRootLogin yes" > /etc/ssh/sshd_config.d/packer.conf
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config.d/packer.conf

systemctl restart sshd

echo "==> Remove unnecessary packages"
dnf -y remove linux-firmware || true

echo "==> System tuning"
echo "virtual-guest" > /etc/tuned/active_profile

echo "==> Clean machine-id"
truncate -s 0 /etc/machine-id

echo "==> Clean logs"
rm -rf /var/log/*

echo "==> Fix SELinux contexts"
touch /var/log/cron
touch /var/log/boot.log
mkdir -p /var/cache/dnf
restorecon -Rv /etc/ssh
restorecon -Rv /root
touch /.autorelabel
/usr/sbin/fixfiles -R -a restore || true

echo "==> Disable tmpfs /tmp"
systemctl mask tmp.mount

echo "==> Enable services"
systemctl enable sshd
dnf install -y qemu-guest-agent
systemctl enable qemu-guest-agent

echo "==> DNF clean"
dnf clean all

echo "==> Done"

%end

reboot --eject
