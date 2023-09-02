#!/bin/bash
if ! command -v git >/dev/null; then
    echo "git is not installed! It used git clone command."
    exit 1
fi

if ! command -v aws >/dev/null; then
    echo "AWS CLI is not installed! Import Certs to ACM need AWS CLI."
    exit 1
fi

if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "AWS profile is not invalid!"
    exit 1
fi

# https://github.com/OpenVPN/easy-rsa/blob/v3.0.6/README.quickstart.md
mkdir vpn-ca && cd ./vpn-ca
git clone https://github.com/OpenVPN/easy-rsa.git

# init pki
cd easy-rsa/easyrsa3
./easyrsa init-pki

# build new CA
## CA name set "test"
echo "test" | ./easyrsa build-ca nopass

# create server cert & key
echo "yes" | ./easyrsa build-server-full server nopass

# create client cert & key
echo "yes" | ./easyrsa build-client-full client1.domain.tld nopass

# copy certs & keys for import
cd ../../ && mkdir certificates
cp ./easy-rsa/easyrsa3/pki/ca.crt ./certificates
cp ./easy-rsa/easyrsa3/pki/issued/server.crt ./certificates
cp ./easy-rsa/easyrsa3/pki/private/server.key ./certificates
cp ./easy-rsa/easyrsa3/pki/issued/client1.domain.tld.crt ./certificates
cp ./easy-rsa/easyrsa3/pki/private/client1.domain.tld.key ./certificates
cd ./certificates

# import cert on AWS ACM
aws acm import-certificate --certificate fileb://server.crt --private-key fileb://server.key --certificate-chain fileb://ca.crt > /dev/null
if [ $? -eq 0 ]; then echo "Server Certs is imported successfully!" 
fi

aws acm import-certificate --certificate fileb://client1.domain.tld.crt --private-key fileb://client1.domain.tld.key --certificate-chain fileb://ca.crt > /dev/null
if [ $? -eq 0 ]; then echo "Client Certs is imported successfully!"
fi