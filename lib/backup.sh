#!/bin/bash 

cp $scripts_dir/lib/backup.service /etc/systemd/system/backup.service
cp $scripts_dir/lib/backup.timer /etc/systemd/system/backup.timer

sed -i "s|BUCKET_NAME|${s3_bucket_name}|g" /etc/systemd/system/backup.service
sed -i "s|S3_PATH|${s3_dir}|g" /etc/systemd/system/backup.service

systemctl daemon-reload

systemctl enable backup.service
systemctl disable backup.timer

systemctl start backup.service
systemctl stop backup.timer

# you can chek timer with: systemctl list-timers