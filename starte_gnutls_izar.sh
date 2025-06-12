#!/bin/bash

# ausführbar machen mit chmod +x XXX.sh
# starte mit ./XXX.sh

# Finde laufende Python Prozesse: ps aux | grep '[p]ython'
RSA=1

if [ "$RSA" -eq 1 ]; then
# Startet Server explizit mit RSA (ohne ECC) Unterstützung
gnutls-cli \
  ma000002.izar-test.com:443 \
    --priority "NORMAL:-VERS-TLS1.3:+VERS-TLS1.2:+RSA" \
  --debug=9000

else
# Startet Server explizit mit ECC (ohne RSA) Unterstützung
gnutls-cli \
  ma000002.izar-test.com:443 \
  --priority "NONE:+VERS-TLS1.2:+ECDHE-ECDSA:+AES-128-GCM:+AEAD:+MAC-ALL:+CURVE-ALL:+SIGN-ECDSA-SHA256:+COMP-NULL" \
  --debug=9000
fi
