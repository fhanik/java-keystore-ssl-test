#!/bin/bash

CUR_DIR=`pwd`

BASE_DIR=`dirname "$(readlink -f "$0")"`
export BASE_DIR
echo $BASE_DIR

set -x -e

cd $BASE_DIR

openssl genrsa -passout pass:password -des3 -out private/cakey.pem 4096

openssl req -passin pass:password -new -x509 -key private/cakey.pem -out cacert.pem -days 3650 -set_serial 0 -subj "/C=US/ST=Colorado/L=Castle Rock/O=Filips Certificate Authority/OU=IT Department/CN=Filips Certificate Authority"

cd $BASE_DIR/requests

openssl genrsa -passout pass:password -des3 -out webserverkey.pem 2048

#generate the *.127.0.0.1.xip.io cert
openssl req -passin pass:password -new -key webserverkey.pem -out webservercert.csr -days 3650 -config ../config.txt -subj "/C=US/ST=Colorado/L=Castle Rock/O=Filips WebServer Level 1/OU=IT Department/CN=*.127.0.0.1.xip.io"
openssl ca -batch -passin pass:password -in webservercert.csr -out webservercert.pem -config $BASE_DIR/config.txt

openssl rsa -passin pass:password -in webserverkey.pem -out webserverkey_nopasswd.pem

openssl x509 -in webservercert.pem -text -noout

cd $CUR_DIR

