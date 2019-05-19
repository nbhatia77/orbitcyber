#!/bin/bash

# Install openswan
apt-get update -y
apt-get install -y openswan

# Configure ipv4 settings
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_redirects=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.send_redirects=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.send_redirects=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.eth0.send_redirects=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_redirects=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.eth0.accept_redirects=0" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

# Configure openswan
sed -i 's/#plutostderrlog=\/dev\/null/plutostderrlog=\/var\/log\/pluto.log/g' /etc/ipsec.conf
echo 'include /etc/ipsec.d/*.conf' >> /etc/ipsec.conf

cat <<EOT >> /etc/ipsec.d/${env}-to-devops.conf
conn ${env}-to-devops
  type=tunnel
  authby=secret
  left=
  leftid=${ipsec_public_eip}
  leftsubnet=${ipsec_cidr}
  right=${devops_ipsec_public_ip}
  rightsubnet=${devops_ipsec_cidr}
  pfs=yes
  auto=start
EOT
private_ip=`ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1`
sed -i "s/left=/left=$private_ip/g" /etc/ipsec.d/derms01-to-devops.conf

echo ${ipsec_public_eip} ${devops_ipsec_public_ip}: PSK \"$(date +%s | shasum -a 256 | base64 | head -c 48)\" >> /etc/ipsec.secrets

sudo service ipsec restart
sudo ipsec secrets reload
ipsec auto --add ${env}-to-devops
ipsec auto --up ${env}-to-devops
