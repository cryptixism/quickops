#!/bin/bash
set -eux

mkdir -p /etc/apt/keyrings
wget https://packages.openvpn.net/as-repo-public.asc -qO /etc/apt/keyrings/as-repository.asc

echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/as-repository.asc] http://packages.openvpn.net/as/debian jammy main" > /etc/apt/sources.list.d/openvpn-as-repo.list

apt-get update -y
apt-get install -y openvpn-as

source $scripts_dir/lib/openvpnas/restore.sh

chown openvpn_as:openvpn_as /usr/local/openvpn_as/etc/db/*.db /usr/local/openvpn_as/etc/as.conf

systemctl restart openvpnas

systemctl enable openvpnas
systemctl start openvpnas

# enable backup service

cp $scripts_dir/lib/openvpnas/backup.service /etc/systemd/system/backup.service
sed -i "s|SCRIPT_DIR|${scripts_dir}|g" /etc/systemd/system/backup.service

systemctl daemon-reload
systemctl enable backup.service
systemctl start backup.service
