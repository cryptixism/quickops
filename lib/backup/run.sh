#!/bin/bash 

cp $scripts_dir/lib/backup.service /etc/systemd/system/backup.service

sed -i "s|BUCKET_NAME|${s3_bucket_name}|g" /etc/systemd/system/backup.service
sed -i "s|S3_PATH|${s3_dir}|g" /etc/systemd/system/backup.service

systemctl daemon-reload
systemctl enable backup.service
systemctl start backup.service
