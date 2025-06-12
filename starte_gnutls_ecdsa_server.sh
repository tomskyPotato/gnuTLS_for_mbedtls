#!/bin/bash

# ausführbar machen mit chmod +x XXX.sh
# starte mit ./XXX.sh

# Finde laufende Python Prozesse: ps aux | grep '[p]ython'

# Startet Server explizit mit ECDSA (ohne RSA) Unterstützung
gnutls-serv \
    --port 5690 \
    --echo \
    --x509certfile ca_root_cert_and_keys/public/ca_public_ecdsa_weptech_iot_de.crt \
    --x509keyfile ca_root_cert_and_keys/private/ca_private_ecdsa_weptech_iot_de.key \
    --priority "NORMAL:-VERS-TLS1.3:+VERS-TLS1.2:+ECDHE-ECDSA" \
    --debug=9000