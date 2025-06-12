# Funktion zur Erstellung eines gültigen PEM-Headers mit Byte-Länge für mbedtls
generate_pem_header() {
    local CERT_FILE="$1"
    local HEADER_FILE="$2"
    local VAR_NAME="$3"

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
generate_pem_header "DigiCertGlobalRootG2.crt.pem" "DigiCertGlobalRootG2.h" "DigiCertGlobalRootG2"