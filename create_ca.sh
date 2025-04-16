#!/bin/bash

# ausführbar machen mit chmod +x create_ca.sh
# starte mit ./create_ca.sh

set -e

CA_NAME="weptech-iot.de"
SAFE_NAME="${CA_NAME//[^a-zA-Z0-9]/_}"  # ersetzt alle Nicht-Buchstaben/Ziffern durch "_"

mkdir -p keys certs

echo "=== Erstelle RSA CA ==="
openssl genrsa -out keys/ca_rsa_${SAFE_NAME}.key 2048
openssl req -new -x509 -key keys/ca_rsa_${SAFE_NAME}.key -out certs/ca_rsa_${SAFE_NAME}.crt -days 3650 -subj "/CN=MyRSA CA ${CA_NAME}"

echo "=== Erstelle ECDSA CA ==="
openssl ecparam -name secp256r1 -genkey -out keys/ca_ecdsa_${SAFE_NAME}.key
openssl req -new -x509 -key keys/ca_ecdsa_${SAFE_NAME}.key -out certs/ca_ecdsa_${SAFE_NAME}.crt -days 3650 -subj "/CN=MyECDSA CA ${CA_NAME}"

echo "CA-Zertifikate für ${CA_NAME} fertig."
