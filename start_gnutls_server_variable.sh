#!/bin/bash

# ausführbar machen mit chmod +x XXX.sh
# starte mit ./XXX.sh

# Finde laufende Python Prozesse: ps aux | grep '[p]ython'

# Starte Server mit TLS 1.2, akzeptiert RSA und ECDSA Zertifikate
gnutls-serv \
  --port 5690 \
  --echo \
  --x509certfile certs/combined_weptech_iot_de.crt \
  --x509keyfile keys/combined_weptech_iot_de.key \
  --priority "NORMAL:-VERS-TLS1.3:+VERS-TLS1.2" \
  --debug=1
