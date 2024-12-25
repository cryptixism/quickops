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

# Configure easy-rsa
make-cadir $EASYRSA_DIR
mkdir -p $KEY_DIR $CLIENT_DIR

cp $scripts_dir/lib/openvpn/client.ovpn $CLIENT_CONFIG
cp $scripts_dir/lib/openvpn/server.conf $SERVER_CONFIG

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

ca_cert=$(cat /etc/openvpn/ca.crt)

# Replace variables in client config
sed -i -e "s/SERVER_ADDRESS/${domain_name}/g" $CLIENT_CONFIG
sed -i -e "s/SERVER_PORT/${openvpn_port}/g" $CLIENT_CONFIG
sed -i -e "s/SERVER_CA/${ca_cert}/g" $CLIENT_CONFIG
sed -i -e "s/SERVER_PORT/${openvpn_port}/g" $SERVER_CONFIG
echo -e "\nCLient config:\n" && cat $CLIENT_CONFIG

# Start OpenVPN service
systemctl start openvpn@server
systemctl enable openvpn@server
