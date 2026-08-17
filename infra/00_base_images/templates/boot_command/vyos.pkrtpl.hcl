<enter><wait>
<wait30>
${vm_config.ssh_username}<wait>
<enter><wait>
${vm_config.ssh_username}<wait>
<enter><wait>
install image<wait>
<enter><wait>
<wait5>
y<wait>
<enter><wait>
<wait5>
<enter><wait>
<wait5>
${user_password}<wait>
<enter><wait>
<wait5>
${user_password}<wait>
<enter><wait>
<wait5>
<enter><wait>
<wait5>
<enter><wait>
<wait5>
y<wait>
<enter><wait>
<wait5>
<enter><wait>
<wait20>
<enter><wait>
<wait20>
reboot<wait>
<enter><wait>
<wait5>
y<enter><wait>
<wait30>
<enter><wait>
<wait30>
${vm_config.ssh_username}<wait>
<enter><wait>
${user_password}<wait>
<enter><wait>
<wait5>
configure<wait>
<enter><wait>
<wait5>
set service ssh port 22<wait>
<enter><wait>
<wait5>
set system login user vyos authentication public-keys default type ssh-ed25519<wait>
<enter><wait>
<wait5>
set system login user vyos authentication public-keys default key '${ssh_public_key}'<wait>
<enter><wait>
<wait5>
set interfaces ethernet eth0 address '${vm_config.ip}/${vm_config.cidr}'<wait>
<enter><wait>
<wait5>
set protocols static route 0.0.0.0/0 next-hop '${vm_config.gateway}'<wait>
<enter><wait>
<wait5>
set service dns forwarding dhcp eth0<wait>
<enter><wait>
<wait5>
set service dns forwarding allow-from '127.0.0.0/8'<wait>
<enter><wait>
<wait5>
set service dns forwarding listen-address '127.0.0.1'<wait>
<enter><wait>
<wait5>
set system name-server '127.0.0.1'<wait>
<enter><wait>
<wait5>
commit<wait>
<enter><wait>
<wait5>
save<wait>
<enter><wait>
<wait5>
exit<wait>
<enter><wait>
echo "deb http://deb.debian.org/debian bookworm main contrib non-free" | sudo tee /etc/apt/sources.list.d/debian_temp.list<enter><wait>
sudo apt-get update<enter><wait20>
sudo apt-get install -y qemu-guest-agent<enter><wait20>
sudo systemctl enable --now qemu-guest-agent<enter><wait>
sudo rm /etc/apt/sources.list.d/debian_temp.list<enter><wait>
sudo apt-get update<enter><wait20>
<wait5>