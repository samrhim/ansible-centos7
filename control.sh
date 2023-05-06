#!/bin/sh

echo "Control Node Preparation ..."

yum update -y
yum install -y epel-release wget
yum makecache --refresh
yum install -y python39 python39-pip ansible git bind-utils vim bash-completion libX11
wget http://mirror.centos.org/centos/8-stream/AppStream/x86_64/os/Packages/sshpass-1.09-4.el8.x86_64.rpm
rpm -i sshpass-1.09-4.el8.x86_64.rpm

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

export PATH="/usr/local/bin:$PATH"
source  ~/.bash_profile

PASS=$(echo "control" | openssl passwd -1 -stdin)
useradd -p "$PASS" ansible
cat <<EOF > /etc/sudoers.d/ansible
ansible 	ALL=NOPASSWD: ALL
EOF

ansible --version


cat <<EOF > /etc/hosts
192.168.30.200 master.clevory.local
192.168.30.201 node1.clevory.local
192.168.30.202 node2.clevory.local
EOF

su - ansible -c "ssh-keygen -b 2048 -t rsa -f /home/ansible/.ssh/id_rsa -q -P \"\""
su - ansible -c "ssh-keyscan  node1.clevory.local 2>/dev/null >> home/ansible/.ssh/known_hosts"
su - ansible -c "ssh-keyscan  node2.clevory.local 2>/dev/null >> home/ansible/.ssh/known_hosts"
su - ansible -c "echo 'ansible' |sshpass ssh-copy-id -f -i /home/ansible/.ssh/id_rsa.pub -o StrictHostKeyChecking=no ansible@node1.clevory.local"
su - ansible -c "echo 'ansible' |sshpass ssh-copy-id -f -i /home/ansible/.ssh/id_rsa.pub -o StrictHostKeyChecking=no ansible@node2.clevory.local"
# su - ansible -c "git clone https://github.com/samrhim/rhce8-live.git"
