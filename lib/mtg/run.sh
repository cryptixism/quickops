#!/bin/bash 

aws s3api get-object --bucket "$s3_bucket_name" --key "data/mtg" "$s3_dir/mtg"

cp $s3_dir/mtg /usr/local/bin/mtg
cp $scripts_dir/lib/mtg/mtg.service /etc/systemd/system/mtg.service
cp $scripts_dir/lib/mtg/mtg.toml /etc/mtg.toml

chmod +x /usr/local/bin/mtg

sed -i "s|SECRET_ENV|${mtg_secret}|g" /etc/mtg.toml
sed -i "s|BIND_PORT_ENV|${mtg_port}|g" /etc/mtg.toml

systemctl daemon-reload
systemctl enable mtg
systemctl start mtg
