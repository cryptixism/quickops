#!/bin/bash 
set -x

## env variables
echo "export s3_dir=/opt/s3" >> /env
echo "export s3_bucket_name=${s3_bucket_arn##*:}" >> /env # split arn and take last part
source /env

## handle address updates
source $scripts_dir/lib/address/run.sh

## installing and configuring xui and xray
## https://github.com/MHSanaei/3x-ui
source $scripts_dir/lib/xui/run.sh

## installing and configuring mtg
## https://github.com/9seconds/mtg
source $scripts_dir/lib/mtg/run.sh

## backup service that trigger for interuptions, scale-in events, and terminations
source $scripts_dir/lib/backup/run.sh

## health service that checks health 
source $scripts_dir/lib/health/run.sh
