#!/bin/bash 

export instance_id=$(cat /var/lib/cloud/data/instance-id)
aws ec2 modify-instance-attribute --instance-id ${instance_id} --no-source-dest-check

if [ $eip_allocation_id != "None" ]; then
  aws ec2 associate-address --instance-id ${instance_id} --allocation-id ${eip_allocation_id}
elif [ $afraid_update_key != "None" ]; then
  curl https://freedns.afraid.org/dynamic/update.php?${afraid_update_key}
fi
