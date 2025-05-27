#!/bin/bash

# ausführbar machen mit chmod +x XXX.sh
# starte mit ./XXX.sh

# Finde laufende Python Prozesse: ps aux | grep '[p]ython'
gnutls-cli \
  --debug=9000 \
  --priority "NORMAL:-VERS-ALL:+VERS-TLS1.2:-KX-RSA" \
  ma000002.izar-test.com \
  -p 443

# Starte Client mit Schlüsselaustauschverfahren RSA sowie RSA Zertifikat 
gnutls-cli \
  --x509cafile certs/ca_rsa.crt \
  --debug=1 \
  weptech-iot.de:5690

# Starte Client mit ECDSA und ECDHE
gnutls-cli \
  --x509cafile customer/isrgrootx2.pem \
  --port 443 \
  --debug=1 \
  --priority "NORMAL:-VERS-TLS1.3:+VERS-TLS1.2:+ECDHE-ECDSA" \
  weptech-iot.de