#!/bin/bash 
set -x

export cert_dir=/opt/certs
export arch=amd64

mkdir -p $cert_dir
cp $s3_dir/sib.ftp.sh.cer $cert_dir/
cp $s3_dir/sib.ftp.sh.key $cert_dir/

cp $s3_dir/x-ui.db /etc/x-ui/x-ui.db

latest_tag_version=$(curl -Ls "https://api.github.com/repos/MHSanaei/3x-ui/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
cd /opt
wget -N --no-check-certificate -O /usr/local/x-ui-linux-$(arch).tar.gz https://github.com/MHSanaei/3x-ui/releases/download/${tag_version}/x-ui-linux-$(arch).tar.gz
tar zxvf x-ui-linux-$(arch).tar.gz
rm x-ui-linux-$(arch).tar.gz -f
cd x-ui
chmod +x x-ui
chmod +x x-ui bin/xray-linux-$(arch)
cp -f x-ui.service /etc/systemd/system/
wget --no-check-certificate -O /usr/bin/x-ui https://raw.githubusercontent.com/MHSanaei/3x-ui/main/x-ui.sh
chmod +x /usr/local/x-ui/x-ui.sh
chmod +x /usr/bin/x-ui

# curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh -o install.sh
# sudo bash install.sh

systemctl daemon-reload
systemctl enable x-ui
systemctl restart x-ui
