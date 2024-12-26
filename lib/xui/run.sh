#!/bin/bash 

aws s3api get-object --bucket "$s3_bucket_name" --key "data/xui/${domain_name}.cer" "$s3_dir/${domain_name}.cer"
aws s3api get-object --bucket "$s3_bucket_name" --key "data/xui/${domain_name}.key" "$s3_dir/${domain_name}.key"
source $scripts_dir/lib/xui/db.sh

export cert_dir="/opt/certs"
export arch="amd64"
export xui_version="v2.4.4"

if [ ${domain_name} == "None" ]; then
  echo "Error: domain name is not provided."
fi

mkdir -p $cert_dir
cp $s3_dir/${domain_name}.cer $cert_dir/
cp $s3_dir/${domain_name}.key $cert_dir/

mkdir -p /etc/x-ui
cp $s3_dir/x-ui.db /etc/x-ui/x-ui.db

cd /usr/local
wget -q --timeout 10 --no-check-certificate -O x-ui-linux-${arch}.tar.gz https://github.com/MHSanaei/3x-ui/releases/download/${xui_version}/x-ui-linux-${arch}.tar.gz
tar zxvf x-ui-linux-${arch}.tar.gz
rm x-ui-linux-${arch}.tar.gz -f
cd x-ui
chmod +x x-ui
chmod +x x-ui bin/xray-linux-${arch}
cp -f x-ui.service /etc/systemd/system/

wget -q --timeout 10 --no-check-certificate -O /usr/bin/x-ui https://raw.githubusercontent.com/MHSanaei/3x-ui/main/x-ui.sh
chmod +x /usr/local/x-ui/x-ui.sh
chmod +x /usr/bin/x-ui

systemctl daemon-reload
systemctl enable x-ui
systemctl restart x-ui
