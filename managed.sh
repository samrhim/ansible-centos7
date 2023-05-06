#!/bin/sh

echo "Managed Node Preparation ..."

yum makecache --refresh
yum update -y
yum install -y python39 bind-utils libX11 

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

PASS=$(echo "ansible" | openssl passwd -1 -stdin)
useradd -p "$PASS" ansible
cat <<EOF > /etc/sudoers.d/ansible
ansible ALL=NOPASSWD: ALL
EOF

cat <<EOF > /etc/hosts
192.168.30.200 master.clevory.local
192.168.30.201 node1.clevory.local
192.168.30.202 node2.clevory.local
EOF
