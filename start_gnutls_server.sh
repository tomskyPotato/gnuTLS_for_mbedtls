gnutls-serv --port 5690 --echo --x509certfile combined_server.crt --x509keyfile combined_server.key --priority "NORMAL:-VERS-TLS1.3:+VERS-TLS1.2" --debug 1


# Erstelle RSA-Schlüssel
openssl genrsa -out rsa_server.key 2048

# Erstelle selbstsigniertes RSA-Zertifikat
openssl req -new -x509 -key rsa_server.key -out rsa_server.crt -days 365 -subj "/CN=weptech-iot.de"

# Erstelle ECDSA-Schlüssel (z. B. mit secp256r1)
openssl ecparam -name secp256r1 -genkey -out ecdsa_server.key

# Erstelle selbstsigniertes ECDSA-Zertifikat
openssl req -new -x509 -key ecdsa_server.key -out ecdsa_server.crt -days 365 -subj "/CN=weptech-iot.de"

# Kombiniere Zertifikate für Angebot von RSA und ECDSA 
cat rsa_server.crt ecdsa_server.crt > combined_server.crt
cat rsa_server.key ecdsa_server.key > combined_server.key