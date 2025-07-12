#!/bin/bash
set -eux

mkdir -p /etc/apt/keyrings
wget https://packages.openvpn.net/as-repo-public.asc -qO /etc/apt/keyrings/as-repository.asc

echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/as-repository.asc] http://packages.openvpn.net/as/debian jammy main" > /etc/apt/sources.list.d/openvpn-as-repo.list

apt-get update -y
apt-get install -y openvpn-as build-essential gcc-12 g++-12

# install ovpn-dco kernel module
git clone https://github.com/OpenVPN/ovpn-dco.git
cd ovpn-dco
make CC=gcc-12
make install
depmod -a
modprobe ovpn-dco-v2

# restore configuration

source $scripts_dir/lib/openvpnas/restore.sh
# chown openvpn_as:openvpn_as /usr/local/openvpn_as/etc/db/*.db /usr/local/openvpn_as/etc/as.conf
systemctl restart openvpnas

# enable backup service

cp $scripts_dir/lib/openvpnas/backup.service /etc/systemd/system/backup.service
sed -i "s|SCRIPT_DIR|${scripts_dir}|g" /etc/systemd/system/backup.service

systemctl daemon-reload
systemctl enable backup.service
systemctl start backup.service


# sudo /usr/local/openvpn_as/scripts/openvpnas --nodaemon
