#!/bin/bash
set +x

API_ADDR="http://169.254.169.254/latest"
TOKEN_HEADER="NO_TOKEN"

get_new_token () {
  echo 'Getting new authentication token.' && date
  TOKEN=`curl -s -X PUT "${API_ADDR}/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
  TOKEN_HEADER="X-aws-ec2-metadata-token: ${TOKEN}"
}

prepare_for_shutdown () {
  echo 'Getting prepared for shutting down server.' && date
  aws s3 sync ${s3_dir}/ s3://${s3_bucket_name}/data
}

while sleep 2; do

  ## spot interuption protection

  HTTP_CODE=$(curl -s -H "${TOKEN_HEADER}" -s -w %{http_code} -o /dev/null "${API_ADDR}/meta-data/spot/instance-action")

  if [[ "${HTTP_CODE}" -eq 401 ]] ; then
    get_new_token
  elif [[ "${HTTP_CODE}" -eq 200 ]] ; then
    prepare_for_shutdown
    break
  fi

  ## scale in protection

  LIFECYCLE_STATE=$(curl -s -H "${TOKEN_HEADER}" "${API_ADDR}/meta-data/autoscaling/target-lifecycle-state")

  if [[ "${LIFECYCLE_STATE}" == "Terminated" ]]; then
    prepare_for_shutdown
    break
  fi

done