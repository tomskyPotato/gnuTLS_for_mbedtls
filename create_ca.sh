#!/bin/bash

# Ausführbar machen mit chmod +x create_ca.sh
# Starte mit ./create_ca.sh

set -e

CA_NAME="weptech-iot.de"
SAFE_NAME="${CA_NAME//[^a-zA-Z0-9]/_}" # ersetzt alle Nicht-Buchstaben/Ziffern durch "_"

# Erstelle die Ordner für private Schlüssel und öffentliche Zertifikate
mkdir -p private public

echo "=== Erstelle RSA CA ==="
# Privater CA-Schlüssel
openssl genrsa -out private/ca_private_rsa_${SAFE_NAME}.key 2048
# Öffentliches CA-Zertifikat, selbst-signiert
openssl req -new -x509 -key private/ca_private_rsa_${SAFE_NAME}.key -out public/ca_public_rsa_${SAFE_NAME}.crt -days 3650 -subj "/CN=MyRSA CA ${CA_NAME}"

echo "=== Erstelle ECDSA CA ==="
# Privater CA-Schlüssel
openssl ecparam -name secp256r1 -genkey -out private/ca_private_ecdsa_${SAFE_NAME}.key
# Öffentliches CA-Zertifikat, selbst-signiert
openssl req -new -x509 -key private/ca_private_ecdsa_${SAFE_NAME}.key -out public/ca_public_ecdsa_${SAFE_NAME}.crt -days 3650 -subj "/CN=MyECDSA CA ${CA_NAME}"

echo "CA-Zertifikate und Schlüssel für ${CA_NAME} fertig. Findest du in den Ordnern 'private' und 'public'."