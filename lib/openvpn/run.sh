#!/bin/bash

## Update and install required packages
apt install -y openvpn 
useradd user1
set +H
echo "user1:${openvpn_user1_password}" | sudo chpasswd
set -H
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -s 10.20.0.0/24 -o ens5 -j MASQUERADE

## Set variables
OPENVPN_DIR="/etc/openvpn"
CLIENT_CONFIG="$OPENVPN_DIR/ccd/user1.ovpn"
SERVER_CONFIG="$OPENVPN_DIR/server.conf"

mkdir -p $OPENVPN_DIR/ccd

## Copy configs
cp $scripts_dir/lib/openvpn/client.ovpn $CLIENT_CONFIG
cp $scripts_dir/lib/openvpn/server.conf $SERVER_CONFIG

## Download certs
aws s3api get-object --bucket "$s3_bucket_name" --key data/openvpn/ca.crt $OPENVPN_DIR/ca.crt
aws s3api get-object --bucket "$s3_bucket_name" --key data/openvpn/dh.pem $OPENVPN_DIR/dh.pem
aws s3api get-object --bucket "$s3_bucket_name" --key data/openvpn/server.crt $OPENVPN_DIR/server.crt
aws s3api get-object --bucket "$s3_bucket_name" --key data/openvpn/server.key $OPENVPN_DIR/server.key
aws s3api get-object --bucket "$s3_bucket_name" --key data/openvpn/ta.key $OPENVPN_DIR/ta.key

## Replace variables in configs
sed -i -e "s/SERVER_PORT/${openvpn_port}/g" $SERVER_CONFIG
sed -i -e "s/SERVER_ADDRESS/${domain_name}/g" $CLIENT_CONFIG
sed -i -e "s/SERVER_PORT/${openvpn_port}/g" $CLIENT_CONFIG

## Add CA certificate to client config
echo -e "<ca>\n" >> $CLIENT_CONFIG
cat $OPENVPN_DIR/ca.crt >> $CLIENT_CONFIG
echo -e "</ca>\n" >> $CLIENT_CONFIG

## Add TLS Auth to client config
echo -e "<tls-auth>\n" >> $CLIENT_CONFIG
cat $OPENVPN_DIR/ta.key >> $CLIENT_CONFIG
echo -e "\n</tls-auth>\n" >> $CLIENT_CONFIG

# Start OpenVPN service
systemctl start openvpn@server
systemctl enable openvpn@server

# troubleshoot
# journalctl -u openvpn@server -f
# tcpdump -i tun0 host 104.26.9.59 -vv
# tcpdump -i tun0 icmp -vv
# ip route show
# route -n