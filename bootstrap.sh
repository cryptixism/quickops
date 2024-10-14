#!/bin/bash 
set -x

## sync data from s3
export s3_dir=/opt/s3
export s3_bucket_name=${s3_bucket_arn##*:}
aws s3 sync s3://${s3_bucket_name}/data $s3_dir/
chmod +x -R $s3_dir/

## handle address updates
sudo ./lib/address.sh

## installing and configuring xui and xray
## https://github.com/MHSanaei/3x-ui
sudo ./lib/xui.sh

## installing and configuring mtg
## https://github.com/9seconds/mtg
sudo ./lib/mtg.sh

## lookout for interuptions
sudo ./lib/notice.sh
