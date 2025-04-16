#!/bin/bash

# ausführbar machen mit chmod +x XXX.sh
# starte mit ./XXX.sh

# Startet Server explizit mit ECDSA (ohne RSA) Unterstützung
gnutls-serv \
    --port 5690 \
    --echo \
    --x509certfile certs/ecdsa_weptech_iot_de.crt \
    --x509keyfile keys/ecdsa_weptech_iot_de.key \
    --priority "NORMAL:-VERS-TLS1.3:+VERS-TLS1.2:+ECDHE-ECDSA" \
    --debug=1