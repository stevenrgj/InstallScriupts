#!/bin/bash
#author:steven
if [ x$1 = x"" ]
then
echo $0" yourdomain"
exit 0
fi
YOURDOAMIN=$1
#1、***********************************************************************
openssl genrsa -out ca.key 4096
#2、***********************************************************************
openssl req -x509 -new -nodes -sha512 -days 3650 \
    -subj "/C=TW/ST=Taipei/L=Taipei/O=example/OU=Personal/CN=${YOURDOAMIN}" \
    -key ca.key \
    -out ca.crt
#3、***********************************************************************
openssl genrsa -out ${YOURDOAMIN}.key 4096
#4、***********************************************************************
openssl req -sha512 -new \
    -subj "/C=TW/ST=Taipei/L=Taipei/O=example/OU=Personal/CN=${YOURDOAMIN}" \
    -key ${YOURDOAMIN}.key \
    -out ${YOURDOAMIN}.csr 
#5、***********************************************************************
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth 
subjectAltName = @alt_names
[alt_names]
DNS.1=${YOURDOAMIN}
DNS.2=`hostname`
EOF
#6、***********************************************************************
  openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in ${YOURDOAMIN}.csr \
    -out ${YOURDOAMIN}.crt