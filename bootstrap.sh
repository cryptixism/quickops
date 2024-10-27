#!/bin/bash 
set -x

## sync data from s3
export s3_dir="/opt/s3"
export s3_bucket_name=${s3_bucket_arn##*:} # split arn and take last part
aws s3 sync s3://${s3_bucket_name}/data $s3_dir/

## handle address updates
source $scripts_dir/lib/address.sh

## installing and configuring xui and xray
## https://github.com/MHSanaei/3x-ui
source $scripts_dir/lib/xui.sh

## installing and configuring mtg
## https://github.com/9seconds/mtg
source $scripts_dir/lib/mtg.sh

## lookout for interuptions
# source $scripts_dir/lib/notice.sh

## backup service that trigger for interuptions, scale-in events, and terminations
source $scripts_dir/lib/backup.sh
