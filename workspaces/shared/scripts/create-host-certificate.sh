#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

SECRETS_SRC_DIR=/opt/localgwms/secrets
SECRETS_DIR=/opt/gwms/secrets
PASSPHRASE="glideinwms"

help_msg() {
    cat << EOF
$0 [options]
Initialize the self-signed GlideinWMS host certificate
  -h       print this message
  -v       verbose mode
  -s DIR   secrets source directory (default: $SECRETS_SRC_DIR)
  -d DIR   secrets directory (default: $SECRETS_DIR)
  -p PASS  passphrase
EOF
}

while getopts "hvs:d:p:" option
do
  case "${option}"
    in
    h) help_msg; exit 0;;
    v) VERBOSE=yes;;
    s) SECRETS_SRC_DIR=$OPTARG;;
    d) SECRETS_DIR=$OPTARG;;
    p) PASSPHRASE=$OPTARG;;
    *) echo "Invalid option: ${option}"; help_msg; exit 1;;
  esac
done

# Set the file paths and details for the certificate
CA_CERT="$SECRETS_DIR/gwms-workspace-ca-cert.pem"
CA_KEY="$SECRETS_DIR/gwms-workspace-ca-key.pem"
KEY_FILE="/etc/grid-security/hostkey.pem"
CERT_FILE="/etc/grid-security/hostcert.pem"
COMMON_NAME="$HOSTNAME"
VALIDITY_PERIOD=365

# Copy the CA files if not already in the shared directory
if [[ ! -f "$CA_CERT" || ! -f "$CA_KEY" ]]; then
    [[ -n "$VERBOSE" ]] && echo "Copying CA files to the shared directory"
    mkdir -p "$SECRETS_DIR"
    cp "$SECRETS_SRC_DIR"/* "$SECRETS_DIR"/
fi

# Generate a private key
openssl genpkey -algorithm RSA -out "$KEY_FILE" -pass pass:"$PASSPHRASE"

# Generate a certificate signing request (CSR)
openssl req -new -key "$KEY_FILE" -out "$CERT_FILE" -subj "/C=US/ST=Illinois/L=Batavia/O=GlideinWMS/CN=$COMMON_NAME"

# Generate a self-signed certificate using the CSR and the CA secrets
openssl x509 -req -in "$CERT_FILE" -CA "$CA_CERT" -CAkey "$CA_KEY" -out "$CERT_FILE" -days "$VALIDITY_PERIOD"

cp "$CA_CERT" /etc/pki/ca-trust/source/anchors/
update-ca-trust extract

# If mod_ssl is installed, use the generated key and certificate for the Web server
mod_ssl_conf=/etc/httpd/conf.d/ssl.conf
if [[ -f "$mod_ssl_conf" ]]; then
    sed -i -e "/^SSLCertificateFile /c\SSLCertificateFile $CERT_FILE" \
        -e "/^SSLCertificateKeyFile /c\SSLCertificateKeyFile $KEY_FILE" "$mod_ssl_conf"
    /sbin/service httpd reload > /dev/null 2>&1 || true
fi
