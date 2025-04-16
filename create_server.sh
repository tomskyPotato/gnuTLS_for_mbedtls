#!/bin/bash

# ausführbar machen mit chmod +x create_server.sh
# starte mit ./create_server.sh

set -e

SERVER_NAME="weptech-iot.de"
SAFE_NAME="${SERVER_NAME//[^a-zA-Z0-9]/_}"

mkdir -p keys certs "certs/mbedtls"

echo "=== Erstelle RSA Server-Key ==="
openssl genrsa -out keys/rsa_${SAFE_NAME}.key 2048

echo "=== Erstelle ECDSA Server-Key ==="
openssl ecparam -name secp256r1 -genkey -out keys/ecdsa_${SAFE_NAME}.key

echo "=== RSA Server-Zertifikat signieren ==="
openssl req -new -key keys/rsa_${SAFE_NAME}.key -out keys/rsa_${SAFE_NAME}.csr -subj "/CN=${SERVER_NAME}"
openssl x509 -req -in keys/rsa_${SAFE_NAME}.csr -CA certs/ca_rsa_${SAFE_NAME}.crt -CAkey keys/ca_rsa_${SAFE_NAME}.key -CAcreateserial -out certs/rsa_${SAFE_NAME}.crt -days 365

echo "=== ECDSA Server-Zertifikat signieren ==="
openssl req -new -key keys/ecdsa_${SAFE_NAME}.key -out keys/ecdsa_${SAFE_NAME}.csr -subj "/CN=${SERVER_NAME}"
openssl x509 -req -in keys/ecdsa_${SAFE_NAME}.csr -CA certs/ca_ecdsa_${SAFE_NAME}.crt -CAkey keys/ca_ecdsa_${SAFE_NAME}.key -CAcreateserial -out certs/ecdsa_${SAFE_NAME}.crt -days 365

echo "=== Kombiniere Zertifikate und Schlüssel ==="
cat certs/rsa_${SAFE_NAME}.crt certs/ecdsa_${SAFE_NAME}.crt > certs/combined_${SAFE_NAME}.crt
cat keys/rsa_${SAFE_NAME}.key keys/ecdsa_${SAFE_NAME}.key > keys/combined_${SAFE_NAME}.key
cat certs/ca_rsa_${SAFE_NAME}.crt certs/ca_ecdsa_${SAFE_NAME}.crt > certs/ca_combined_${SAFE_NAME}.crt

echo "=== Aufräumen ==="
rm -f keys/*.csr certs/*.csr keys/*.srl certs/*.srl

# Funktion zur Erstellung eines gültigen PEM-Headers mit Byte-Länge
generate_pem_header() {
    local CERT_FILE="$1"
    local HEADER_FILE="$2"
    local VAR_NAME="$3"
    local SECTION="$4"

    echo "=== Erzeuge Header: $HEADER_FILE ==="
    {
        echo "const char ${VAR_NAME}[] ="
        awk '{ gsub(/"/, "\\\""); print "\"" $0 "\\r\\n\"" }' "$CERT_FILE"
        echo ";"
        LENGTH=$(awk '{ total += length($0) + 2 } END { print total + 1 }' "$CERT_FILE")
        echo "const size_t ${VAR_NAME}_len = ${LENGTH};"
    } > "$HEADER_FILE"
}

generate_pem_header "certs/ca_rsa_${SAFE_NAME}.crt" "certs/mbedtls/ca_rsa_${SAFE_NAME}.h" "ca_rsa_crt" "credentials"
generate_pem_header "certs/ca_ecdsa_${SAFE_NAME}.crt" "certs/mbedtls/ca_ecdsa_${SAFE_NAME}.h" "ca_ecdsa_crt" "credentials"

echo "Server-Zertifikate für ${SERVER_NAME} fertig."