#!/bin/bash

# ausführbar machen mit chmod +x XXX.sh
# starte mit ./XXX.sh

# Starte Server mit TLS 1.2, akzeptiert RSA und ECDSA Zertifikate
gnutls-serv \
  --port 5690 \
  --echo \
  --x509certfile certs/combined_server.crt \
  --x509keyfile keys/combined_server.key \
  --priority "NORMAL:-VERS-TLS1.3:+VERS-TLS1.2" \
  --debug=1
