#!/bin/bash
set -eux

source /env

# Variables
S3_BUCKET="${s3_bucket_name}"
S3_PATH="openvpnas_backup"

# Files and their paths
declare -A FILES
FILES=(
  [config.db]="/usr/local/openvpn_as/etc/db/config.db"
  [certs.db]="/usr/local/openvpn_as/etc/db/certs.db"
  [userprop.db]="/usr/local/openvpn_as/etc/db/userprop.db"
  [log.db]="/usr/local/openvpn_as/etc/db/log.db"
  [as.conf]="/usr/local/openvpn_as/etc/as.conf"
  [config_local.db]="/usr/local/openvpn_as/etc/db/config_local.db"
  [cluster.db]="/usr/local/openvpn_as/etc/db/cluster.db"
  [notification.db]="/usr/local/openvpn_as/etc/db/notification.db"
)

# Restore files from S3
for file in "${!FILES[@]}"; do
  FILE_PATH="${FILES[$file]}"
  if aws s3 ls "s3://$S3_BUCKET/$S3_PATH/$file" >/dev/null 2>&1; then
    aws s3 cp "s3://$S3_BUCKET/$S3_PATH/$file" "$FILE_PATH"
  else
    echo "Skipping $file: not found in S3."
  fi
done

# Set correct ownership
chown openvpn_as:openvpn_as /usr/local/openvpn_as/etc/db/*.db /usr/local/openvpn_as/etc/as.conf

echo "Restore completed successfully."