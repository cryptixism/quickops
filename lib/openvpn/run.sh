#!/bin/bash

# Update and install required packages
apt install -y openvpn easy-rsa
useradd user1
echo "user1:${OPENVPN_USER1_PASSWORD}" | sudo chpasswd

# Set variables
EASYRSA_DIR="/etc/openvpn/easy-rsa"
KEY_DIR="$EASYRSA_DIR/keys"
USER="user1"
CLIENT_CONFIG="/etc/openvpn/ccd/${USER}.ovpn"
SERVER_CONFIG="/etc/openvpn/server.conf"

cp client.ovpn $CLIENT_CONFIG
cp server.conf $SERVER_CONFIG

# Configure easy-rsa
make-cadir $EASYRSA_DIR
mkdir -p $KEY_DIR
cd $EASYRSA_DIR
./easyrsa init-pki
echo -e "yes\n" | ./easyrsa build-ca nopass
./easyrsa gen-dh
echo -e "yes\n" | ./easyrsa build-server-full server nopass
# ./easyrsa build-client-full $USER nopass
openvpn --genkey secret $KEY_DIR/ta.key

# Copy server keys and certificates
cp $EASYRSA_DIR/pki/ca.crt /etc/openvpn/
cp $EASYRSA_DIR/pki/private/server.key /etc/openvpn/
cp $EASYRSA_DIR/pki/issued/server.crt /etc/openvpn/ 
cp $EASYRSA_DIR/pki/dh.pem /etc/openvpn/
cp $KEY_DIR/ta.key /etc/openvpn/

# Replace variables in client config
sed -i -e "s/SERVER_ADDRESS/${domain_name}/g" $CLIENT_CONFIG
sed -i -e "s/SERVER_PORT/${openvpn_port}/g" $CLIENT_CONFIG
sed -i -e "s/SERVER_PORT/${openvpn_port}/g" $SERVER_CONFIG
echo -e "\nCLient config:\n" && cat $CLIENT_CONFIG

# Start OpenVPN service
systemctl start openvpn@server
systemctl enable openvpn@server
