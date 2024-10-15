#!/bin/bash 

export cert_dir="/opt/certs"
export arch="amd64"
export xui_version="v2.4.4"

mkdir -p $cert_dir
cp $s3_dir/sib.ftp.sh.cer $cert_dir/
cp $s3_dir/sib.ftp.sh.key $cert_dir/

cp $scripts_dir/lib/xui.service /etc/systemd/system/x-ui.service

mkdir -p /etc/x-ui
cp $s3_dir/x-ui.db /etc/x-ui/x-ui.db

cd /opt
wget -q --timeout 10 --no-check-certificate -O x-ui-linux-${arch}.tar.gz https://github.com/MHSanaei/3x-ui/releases/download/${xui_version}/x-ui-linux-${arch}.tar.gz
tar zxvf x-ui-linux-${arch}.tar.gz
rm x-ui-linux-${arch}.tar.gz -f
cd x-ui
chmod +x x-ui
chmod +x x-ui bin/xray-linux-${arch}
wget -q --timeout 10 --no-check-certificate -O /usr/bin/x-ui https://raw.githubusercontent.com/MHSanaei/3x-ui/main/x-ui.sh
chmod +x /opt/x-ui/x-ui.sh
chmod +x /usr/bin/x-ui

systemctl daemon-reload
systemctl enable x-ui
systemctl restart x-ui
