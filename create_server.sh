#!/bin/bash

# Ausführbar machen mit chmod +x create_server.sh
# Starte mit ./create_server.sh

set -e

SERVER_NAME="weptech-iot.de"
SAFE_NAME="${SERVER_NAME//[^a-zA-Z0-9]/_}"

# Erstelle die neuen Ordnerstrukturen
mkdir -p private public "public/mbedtls"

echo "=== Erstelle RSA Server-Schlüssel ==="
openssl genrsa -out private/server_private_rsa_${SAFE_NAME}.key 2048

echo "=== Erstelle ECDSA Server-Schlüssel ==="
openssl ecparam -name secp256r1 -genkey -out private/server_private_ecdsa_${SAFE_NAME}.key

echo "=== RSA Server-Zertifikat signieren ==="
openssl req -new -key private/server_private_rsa_${SAFE_NAME}.key -out private/server_rsa_${SAFE_NAME}.csr -subj "/CN=${SERVER_NAME}"
# Beachte: Die CA-Zertifikate und -Schlüssel müssen im 'public' bzw. 'private' Ordner liegen.
# Dieses Skript geht davon aus, dass sie VORHER erzeugt wurden.
openssl x509 -req -in private/server_rsa_${SAFE_NAME}.csr -CA public/ca_public_rsa_${SAFE_NAME}.crt -CAkey private/ca_private_rsa_${SAFE_NAME}.key -CAcreateserial -out public/server_public_rsa_${SAFE_NAME}.crt -days 365

echo "=== ECDSA Server-Zertifikat signieren ==="
openssl req -new -key private/server_private_ecdsa_${SAFE_NAME}.key -out private/server_ecdsa_${SAFE_NAME}.csr -subj "/CN=${SERVER_NAME}"
# Beachte: Die CA-Zertifikate und -Schlüssel müssen im 'public' bzw. 'private' Ordner liegen.
# Dieses Skript geht davon aus, dass sie VORHER erzeugt wurden.
openssl x509 -req -in private/server_ecdsa_${SAFE_NAME}.csr -CA public/ca_public_ecdsa_${SAFE_NAME}.crt -CAkey private/ca_private_ecdsa_${SAFE_NAME}.key -CAcreateserial -out public/server_public_ecdsa_${SAFE_NAME}.crt -days 365

echo "=== Kombiniere Zertifikate und Schlüssel ==="
cat public/server_public_rsa_${SAFE_NAME}.crt public/server_public_ecdsa_${SAFE_NAME}.crt > public/server_public_combined_${SAFE_NAME}.crt
cat private/server_private_rsa_${SAFE_NAME}.key private/server_private_ecdsa_${SAFE_NAME}.key > private/server_private_combined_${SAFE_NAME}.key
# Annahme: ca_public_rsa/ecdsa existieren bereits im public-Ordner
cat public/ca_public_rsa_${SAFE_NAME}.crt public/ca_public_ecdsa_${SAFE_NAME}.crt > public/ca_public_combined_${SAFE_NAME}.crt

echo "=== Aufräumen ==="
# CSRs und Serials werden als temporäre Dateien im private-Ordner erstellt und dann gelöscht
rm -f private/*.csr private/*.srl

# Funktion zur Erstellung eines gültigen PEM-Headers mit Byte-Länge für mbedtls
generate_pem_header() {
    local CERT_FILE="$1"
    local HEADER_FILE="$2"
    local VAR_NAME="$3"
    local SECTION="$4" # Nicht direkt im awk/echo verwendet, aber für Kontext nützlich

    echo "=== Erzeuge Header: $HEADER_FILE ==="
    {
        echo "const char ${VAR_NAME}[] ="
        awk '{ gsub(/"/, "\\\""); print "\"" $0 "\\r\\n\"" }' "$CERT_FILE"
        echo ";"
        LENGTH=$(awk '{ total += length($0) + 2 } END { print total + 1 }' "$CERT_FILE")
        echo "const size_t ${VAR_NAME}_len = ${LENGTH};"
    } > "$HEADER_FILE"
}

# Generiere mbedtls Header-Dateien für die öffentlichen CA-Zertifikate
generate_pem_header "public/ca_public_rsa_${SAFE_NAME}.crt" "public/mbedtls/ca_public_rsa_${SAFE_NAME}.h" "ca_rsa_crt" "credentials"
generate_pem_header "public/ca_public_ecdsa_${SAFE_NAME}.crt" "public/mbedtls/ca_public_ecdsa_${SAFE_NAME}.h" "ca_ecdsa_crt" "credentials"

echo "Server-Zertifikate für ${SERVER_NAME} fertig und in 'private'/'public' Ordnern organisiert."