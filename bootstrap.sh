#!/bin/bash 
set -x

## env variables
source /env
export s3_dir=/opt/s3
export s3_bucket_name=${s3_bucket_arn##*:} # split arn and take last part
mkdir -p $s3_dir

## handle address updates
source $scripts_dir/lib/address/run.sh

## installing and configuring mtg
## https://github.com/9seconds/mtg
source $scripts_dir/lib/mtg/run.sh

## installing and configuring xui and xray
## https://github.com/MHSanaei/3x-ui
source $scripts_dir/lib/xui/run.sh

## health service that checks health 
source $scripts_dir/lib/health/run.sh

## backup service that trigger for interuptions, scale-in events, and terminations
source $scripts_dir/lib/backup/run.sh