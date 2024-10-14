#!/bin/bash

while true; do
  if [ -z $(curl -Is http://169.254.169.254/latest/meta-data/spot/instance-action | head -1 | grep 404 | cut -d ' ' -f 2) ]; then
    
    aws s3 sync $s3_dir/ s3://${s3_bucket_name}/data
    echo "Synced. Ready for interuption." && date
    break
  else
    sleep 5 # recommended to check for the interuptions notice every 5 seconds
  fi
done