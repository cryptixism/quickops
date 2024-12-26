#!/bin/bash

## Update and install required packages
apt install -y openvpn 
useradd user1
echo "user1:${openvpn_user1_password}" | sudo chpasswd

## Set variables
OPENVPN_DIR="/etc/openvpn/"
CLIENT_CONFIG="$OPENVPN_DIR/user1.ovpn"
SERVER_CONFIG="$OPENVPN_DIR/server.conf"

## Copy configs
cp $scripts_dir/lib/openvpn/client.ovpn $CLIENT_CONFIG
cp $scripts_dir/lib/openvpn/server.conf $SERVER_CONFIG

## Download certs
aws s3api get-object --bucket "$s3_bucket_name" --key data/openvpn/ca.crt $OPENVPN_DIR/
aws s3api get-object --bucket "$s3_bucket_name" --key data/openvpn/dh.pem $OPENVPN_DIR/
aws s3api get-object --bucket "$s3_bucket_name" --key data/openvpn/server.crt $OPENVPN_DIR/
aws s3api get-object --bucket "$s3_bucket_name" --key data/openvpn/server.key $OPENVPN_DIR/
aws s3api get-object --bucket "$s3_bucket_name" --key data/openvpn/ta.key $OPENVPN_DIR/

## Replace variables in configs
sed -i -e "s/SERVER_PORT/${openvpn_port}/g" $SERVER_CONFIG
sed -i -e "s/SERVER_ADDRESS/${domain_name}/g" $CLIENT_CONFIG
sed -i -e "s/SERVER_PORT/${openvpn_port}/g" $CLIENT_CONFIG

## Add CA certificate to client config
echo -e "<ca>\n" >> $CLIENT_CONFIG
cat ca.crt >> $CLIENT_CONFIG
echo -e "</ca>\n" >> $CLIENT_CONFIG

# Start OpenVPN service
systemctl start openvpn@server
systemctl enable openvpn@server

# troubleshoot
# journalctl -u openvpn@server -f