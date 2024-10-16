# Quick Ops
Deploying xray, x-ui, mtproxy in AWS using spot instances

## Prerequisites
1- manually install the 3x-ui and do the configuration as you wish
2- copy the configurations and the certificates to s3
3- build the mtg and copy binary to s3
4- create an ec2 key pair, download it, and note the name
4- create an eip and note the allocation id

## Deploy via Console
1- go to https://ap-south-1.console.aws.amazon.com/cloudformation  
2- use "create stack" and then "with new resources"  
3- choose "upload a template file" and upload the cfn.yml  
4- in next step check the parameters and provide the required parameters  

## Deploy via CLI
1- install AWS CLI  
2- configure AWS CLI  
3- use following command and change the parameters as needed (see cfn.yml for full list of parameters)

``` bash  
aws cloudformation deploy --template-file /path/to/cfn.yml --stack-name name-of-stack \
  --parameter-overrides KeyPairName='my-key-pair.key' \
  --parameter-overrides TelegramProxySecret='ABCDEF00000000000000000987654321' \
  --parameter-overrides MaxSpotPrice='0.005'
```

## To Do
1- confirm termination and interruptions backup settings
2- if eip allocation id is not provided, update dns 
3- add whatsapp proxy
4- containerize  
5- haproxy as gateway
6- ...