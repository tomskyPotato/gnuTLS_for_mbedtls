# Funktionierender Client
gnutls-cli --insecure --priority "NORMAL:-VERS-TLS1.3:+VERS-TLS1.2:+ECDHE-RSA:-SIGN-ALL:+SIGN-RSA-SHA256" --debug 1 weptech-iot.de:5690