#!/bin/bash 
set -x

export instance_id=$(cat /var/lib/cloud/data/instance-id)

if [ $eip_allocation_id != "None" ]; then
  aws ec2 associate-address --instance-id ${instance_id} --allocation-id ${eip_allocation_id}
fi

