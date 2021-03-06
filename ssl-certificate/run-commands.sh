#!/bin/bash

CUR_DIR=`pwd`

BASE_DIR=`dirname "$(readlink -f "$0")"`
export BASE_DIR
echo $BASE_DIR

set -x -e

cd $BASE_DIR

#reset all our certs
rm -rf private/cakey.pem serial index.txt cacert.pem newcerts/*.pem requests/webserver*.* cacert.jks
touch index.txt
echo '01' > serial

openssl genrsa -passout pass:password -des3 -out private/cakey.pem 4096

openssl req -passin pass:password -new -x509 -key private/cakey.pem -out cacert.pem -days 3650 -set_serial 0 -subj "/C=US/ST=Colorado/L=Castle Rock/O=Filips Certificate Authority/OU=IT Department/CN=Filips Certificate Authority"

keytool -noprompt -keystore cacert.jks -import -file cacert.pem -alias localca -storepass changeit -trustcacerts

cd $BASE_DIR/requests

openssl genrsa -passout pass:password -des3 -out webserverkey.pem 2048

#generate the *.127.0.0.1.xip.io cert
openssl req -passin pass:password -new -key webserverkey.pem -out webservercert.csr -days 3650 -config ../config-req.txt -subj "/C=US/ST=Colorado/L=Castle Rock/O=Filips WebServer Level 1/OU=IT Department/CN=*.127.0.0.1.xip.io"
openssl ca -batch -passin pass:password -in webservercert.csr -out webservercert.pem -config $BASE_DIR/config-ca.txt

openssl rsa -passin pass:password -in webserverkey.pem -out webserverkey_nopasswd.pem

openssl pkcs8 -topk8 -passin pass:password -in webserverkey_nopasswd.pem -inform pem -outform pem -out webserverkey-pkcs8.pem -nocrypt

openssl x509 -in webservercert.pem -text -noout

cd $CUR_DIR

