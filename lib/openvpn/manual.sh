apt-get update && apt-get install -y easy-rsa

# Configure easy-rsa
make-cadir easyrsa
cd easyrsa 
./easyrsa init-pki
echo -e "yes\n" | ./easyrsa build-ca nopass
./easyrsa gen-dh
echo -e "yes\n" | ./easyrsa build-server-full server nopass
openvpn --genkey secret ta.key

aws s3 cp pki/ca.crt s3://$s3_bucket_name/data/openvpn/
aws s3 cp pki/dh.pem s3://$s3_bucket_name/data/openvpn/
aws s3 cp pki/issued/server.crt s3://$s3_bucket_name/data/openvpn/
aws s3 cp pki/private/server.key s3://$s3_bucket_name/data/openvpn/
aws s3 cp ta.key s3://$s3_bucket_name/data/openvpn/