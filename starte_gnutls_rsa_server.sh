#!/bin/bash

# ausführbar machen mit chmod +x XXX.sh
# starte mit ./XXX.sh

# Startet Server explizit mit RSA (ohne ECDSA) Unterstützung
gnutls-serv \
    --port 5690 \
    --echo \
    --x509certfile certs/rsa_weptech_iot_de.crt \
    --x509keyfile keys/rsa_weptech_iot_de.key \
    --priority "NORMAL:-VERS-TLS1.3:+VERS-TLS1.2:+RSA" \
    --debug=1