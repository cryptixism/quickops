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

# Check ownership and permissions, then upload
for file in "${!FILES[@]}"; do
  FILE_PATH="${FILES[$file]}"
  if [ ! -f "$FILE_PATH" ]; then
    echo "Warning: $FILE_PATH does not exist, skipping."
    continue
  fi
  OWNER=$(stat -f '%Su' "$FILE_PATH")
  if [ "$OWNER" != "openvpn" ]; then
    echo "Warning: $FILE_PATH is not owned by openvpn."
  fi
  # Upload to S3 with timestamp
  aws s3 cp "$FILE_PATH" "s3://$S3_BUCKET/$S3_PATH/${file%.db}.${file##*.}"
done

echo "Backup completed successfully."