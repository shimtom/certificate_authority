#!/bin/bash

set -eu

ROOT_CA_PATH=/root/ca
SUB_CA_PATH=/root/subordinate/ca

echo "----> Initialize Root CA"
# Initialize Root CA
mkdir -p ${ROOT_CA_PATH}/certs ${ROOT_CA_PATH}/private ${ROOT_CA_PATH}/crl ${ROOT_CA_PATH}/newcerts
chmod 700 ${ROOT_CA_PATH}/private
echo 01 > ${ROOT_CA_PATH}/serial
cp /dev/null ${ROOT_CA_PATH}/index.txt

# generate Root CA private key (non encrypt)
/usr/bin/openssl genrsa -out ${ROOT_CA_PATH}/private/cakey.pem 4096

# generate Root CA Certificate
/usr/bin/openssl req -config ${ROOT_CA_PATH}/openssl.cnf -new -x509 -extensions v3_ca \
    -days ${CA_VALID_DAYS} \
    -key ${ROOT_CA_PATH}/private/cakey.pem \
    -out ${ROOT_CA_PATH}/cacert.pem \
    -subj "${ROOT_CA_SUBJECT}" \
    -set_serial 0 -sha256

echo "----> Finish"

echo "----> Initialize Subordinate CA"
# Initialize Sub CA
mkdir -p ${SUB_CA_PATH}/certs ${SUB_CA_PATH}/private ${SUB_CA_PATH}/crl ${SUB_CA_PATH}/newcerts
chmod 700 ${SUB_CA_PATH}/private
echo 01 > ${SUB_CA_PATH}/serial
cp /dev/null ${SUB_CA_PATH}/index.txt

# generate Sub CA private key (non encrypt)
/usr/bin/openssl genrsa -out ${SUB_CA_PATH}/private/cakey.pem 4096

# generate CA Certificate
/usr/bin/openssl req -config ${SUB_CA_PATH}/openssl.cnf -new \
    -days ${CA_VALID_DAYS} \
    -key ${SUB_CA_PATH}/private/cakey.pem \
    -out ${SUB_CA_PATH}/cacert_req.pem \
    -subj "${SUB_CA_SUBJECT}" \
    -set_serial 0 -sha256

# Sign Sub CA Certificate with Root CA
/usr/bin/openssl ca -batch -config ${ROOT_CA_PATH}/openssl.cnf \
    -out ${SUB_CA_PATH}/cacert.pem \
    -in ${SUB_CA_PATH}/cacert_req.pem \
    -days ${CA_VALID_DAYS}

echo "----> Finish"

# remove unused file
rm -f ${SUB_CA_PATH}/cacert_req.pem

sleep infinity
