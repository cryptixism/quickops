#!/bin/bash 
set -x

export DEBIAN_FRONTEND=noninteractive

region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
echo "export aws_region=${region}" >> /env

## env variables
source /env
export s3_dir=/opt/s3
export s3_bucket_name=${s3_bucket_arn##*:} # split arn and take last part
echo "export s3_bucket_name=${s3_bucket_name}" >> /env
mkdir -p $s3_dir

## handle address updates
source $scripts_dir/lib/address/run.sh

## installing and configuring mtg
## https://github.com/9seconds/mtg
# source $scripts_dir/lib/mtg/run.sh

## installing and configuring xui and xray
## https://github.com/MHSanaei/3x-ui
# source $scripts_dir/lib/xui/run.sh

## health service that checks health 
# source $scripts_dir/lib/health/run.sh

# ## backup service that trigger for interruptions, scale-in events, and terminations
# source $scripts_dir/lib/backup/run.sh

## installing and configuring openVPN
source $scripts_dir/lib/openvpnas/run.sh

# Final
aws ec2 create-tags --region ${aws_region} --resources ${instance_id} --tags "Key=Name,Value=QuickOpsInstance"
