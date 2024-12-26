#!/bin/bash

# Update and install required packages
apt install -y openvpn easy-rsa
useradd user1
echo "user1:${openvpn_user1_password}" | sudo chpasswd

# Set variables
EASYRSA_DIR="/etc/openvpn/easy-rsa"
KEY_DIR="$EASYRSA_DIR/keys"
CLIENT_DIR="/etc/openvpn/ccd"
USER="user1"
CLIENT_CONFIG="${CLIENT_DIR}/${USER}.ovpn"
SERVER_CONFIG="/etc/openvpn/server.conf"

## Configure easy-rsa
make-cadir $EASYRSA_DIR
mkdir -p $KEY_DIR $CLIENT_DIR

## Certificates
cp $scripts_dir/lib/openvpn/client.ovpn $CLIENT_CONFIG
cp $scripts_dir/lib/openvpn/server.conf $SERVER_CONFIG
cp $scripts_dir/lib/openvpn/openvpn.tls /etc/openvpn/ta.key
cp $s3_dir/${domain_name}.cer /etc/openvpn/server.cer
cp $s3_dir/${domain_name}.key /etc/openvpn/server.key

## CA
wget -q --timeout 10 --no-check-certificate -O isrgrootx1.pem https://letsencrypt.org/certs/isrgrootx1.pem
cp isrgrootx1.pem /etc/openvpn/ca.pem
ca_cert=$(cat /etc/openvpn/ca.pem)

## DH 
cd $EASYRSA_DIR
./easyrsa init-pki
./easyrsa gen-dh
cp $EASYRSA_DIR/pki/dh.pem /etc/openvpn/

# Replace variables in client config
sed -i -e "s/SERVER_ADDRESS/${domain_name}/g" $CLIENT_CONFIG
sed -i -e "s/SERVER_PORT/${openvpn_port}/g" $CLIENT_CONFIG
sed -i -e "s/CA_CONTENT/${ca_cert}/g" $CLIENT_CONFIG
sed -i -e "s|SERVER_PORT|${openvpn_port}|g" $SERVER_CONFIG
echo -e "\nCLient config:\n" && cat $CLIENT_CONFIG

# Start OpenVPN service
systemctl start openvpn@server
systemctl enable openvpn@server

# troubleshoot
# journalctl -u openvpn@server -f