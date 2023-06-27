#!/bin/bash

# Set the file paths and details for the certificate
KEY_FILE="/etc/grid-security/hostkey.pem"
CERT_FILE="/etc/grid-security/hostcert.pem"
PASSPHRASE="glideinwms"
COMMON_NAME="$HOSTNAME"
VALIDITY_PERIOD=365

# Generate a private key
openssl genpkey -algorithm RSA -out "$KEY_FILE" -pass pass:"$PASSPHRASE"

# Generate a certificate signing request (CSR)
openssl req -new -key "$KEY_FILE" -out "$CERT_FILE" -subj "/CN=$COMMON_NAME"

# Generate a self-signed certificate using the CSR
openssl x509 -req -in "$CERT_FILE" -signkey "$KEY_FILE" -out "$CERT_FILE" -days "$VALIDITY_PERIOD"

cp $CERT_FILE /etc/pki/ca-trust/source/anchors/
update-ca-trust extract
