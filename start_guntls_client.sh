#!/bin/bash

# ausführbar machen mit chmod +x XXX.sh
# starte mit ./XXX.sh

# Starte Client mit Schlüsselaustauschverfahren RSA sowie RSA Zertifikat 
gnutls-cli \
  --x509cafile certs/ca_rsa.crt \
  --debug=1 \
  weptech-iot.de:5690

# Starte Client mit ECDSA und ECDHE
gnutls-cli \
  --x509cafile certs/ca_ecdsa.crt \
  --port 5690 \
  --debug=1 \
  weptech-iot.de