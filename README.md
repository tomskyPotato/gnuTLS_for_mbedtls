# TLS-Zertifikate mit OpenSSL und GnuTLS verwenden (für STM32, mbedTLS, Debugging)

Dieses Projekt dient zur Erstellung, Nutzung und Einbettung von RSA- und ECDSA-Zertifikaten für Embedded TLS-Anwendungen auf STM32 (mbedTLS) und zur Nutzung mit einem GnuTLS-Testserver zur Handshake-Analyse.

---

## 📁 Verzeichnisstruktur

```text
gnutls/
├── certs/                          # Enthält alle erzeugten Zertifikate
├── keys/                           # Private Keys der CA und Server
├── certs/mbedtls_certs             # Hier liegen die Dateien die in mbedtls in den ordner inc/mbedtls_swan sollten
├── create_ca.sh                    # Erstellt RSA/ECDSA CAs
├── create_server.sh               # Erstellt Server-Zertifikate
├── start_gnutls_server.sh         # Startet GnuTLS-Testserver mit beiden Zertifikaten
├── start_gnutls_server_rsa.sh     # Startet GnuTLS-Server explizit mit RSA
├── start_gnutls_server_ecdsa.sh   # Startet GnuTLS-Server explizit mit ECDSA
```

---

## 🛠 Vorbereitung

### 1. CA-Zertifikate erstellen
```bash
./create_ca.sh
```
> Erstellt:
- `keys/ca_rsa_<SERVER>.key`, `certs/ca_rsa_<SERVER>.crt`
- `keys/ca_ecdsa_<SERVER>.key`, `certs/ca_ecdsa_<SERVER>.crt`

### 2. Server-Zertifikate erstellen + Header für mbedTLS generieren
```bash
./create_server.sh
```
> Erstellt:
- RSA & ECDSA Server-Zertifikate (signiert mit eigener CA)
- Kombinierte Zertifikate/Keys
- Header-Dateien `ca_rsa_<SERVER>.h`, `ca_ecdsa_<SERVER>.h`  
  → inkl. `const char[]` + `const size_t` Länge (+1 für Nullterminator)

---

## 🚀 TLS-Testserver starten

### 3. GnuTLS mit ECDSA-Zertifikat starten
```bash
./start_gnutls_server_ecdsa.sh
```

### 4. GnuTLS mit RSA-Zertifikat starten
```bash
./start_gnutls_server_rsa.sh
```

### 5. GnuTLS mit beiden kombiniert (automatische Auswahl)
```bash
./start_gnutls_server.sh
```

---

## 📌 Hinweise

- Die PEM-Header können direkt in STM32-Projekte mit mbedTLS eingebunden werden.
- Die Länge (`*_len`) beinhaltet **den Nullterminator** (`+1`).
- GnuTLS läuft auf Port `5000` (IPv4 & IPv6).
- Prioritäten werden per `--priority` gesetzt: z. B. `NORMAL:-VERS-TLS1.3:+VERS-TLS1.2:+RSA`

---

## 🧪 Getestet mit

- `GnuTLS 3.8.x`
- `STM32L471` + `mbedTLS` mit TLS 1.2