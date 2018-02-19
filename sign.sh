#!/bin/bash

set -eu

function help() {
    echo "Usage:  sign [root|sub] [CSRFILE] [DOMAIN] [DAYS]"
}

if [ $1 = "-h" || $1 = "--help"]; then
    help
fi

if [ $1 = "root" ]; then
    CONFIG_FILE=/root/ca/openssl.cnf
elif [ $1 = "sub" ]; then
    CONFIG_FILE=/root/subordinate/ca/openssl.cnf
else
    help
    exit 1
fi

CSR_FILE=$2
DOMAIN=$3
VALID_DAYS=$4

/usr/bin/openssl ca -batch -config ${CONFIG_FILE} \
    -in ${CSR_FILE} \
    -out /export/${DOMAIN}.crt \
    -days ${VALID_DAYS}

echo "----> Generate signed certificate: /export/${DOMAIN}.crt"

exit 0
