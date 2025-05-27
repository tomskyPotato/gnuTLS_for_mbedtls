#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <netdb.h>
#include <gnutls/gnutls.h>
#include "customer/ca_rsa_isrgrootx1.h"  // enthält: const char ca_rsa_isrgrootx1_crt[]

// Debug-Funktion
void my_log_func(int level, const char *msg) {
    fprintf(stderr, "|<%d>| %s", level, msg);
}

// TCP-Verbindung aufbauen
int tcp_connect(const char *hostname, const char *port) {
    struct addrinfo hints = {0}, *res, *p;
    int sockfd;

    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;

    if (getaddrinfo(hostname, port, &hints, &res) != 0) {
        perror("getaddrinfo");
        return -1;
    }

    for (p = res; p != NULL; p = p->ai_next) {
        sockfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol);
        if (sockfd < 0) continue;
        if (connect(sockfd, p->ai_addr, p->ai_addrlen) == 0) break;
        close(sockfd);
    }

    freeaddrinfo(res);
    return (p == NULL) ? -1 : sockfd;
}

int main(void) {
    gnutls_session_t session;
    gnutls_certificate_credentials_t xcred;
    int ret;

    // GnuTLS initialisieren & Debug aktivieren
    gnutls_global_set_log_function(my_log_func);
    gnutls_global_set_log_level(4); // 0 = aus, 9 = sehr ausführlich
    gnutls_global_init();

    // TLS-Session vorbereiten
    gnutls_init(&session, GNUTLS_CLIENT);
    gnutls_set_default_priority(session);
    gnutls_server_name_set(session, GNUTLS_NAME_DNS, "weptech-iot.de", strlen("weptech-iot.de"));

    // Zertifikate laden
    gnutls_certificate_allocate_credentials(&xcred);
    gnutls_datum_t ca = {
        .data = (unsigned char *)ca_rsa_isrgrootx1_crt,
        .size = strlen(ca_rsa_isrgrootx1_crt)
    };

    ret = gnutls_certificate_set_x509_trust_mem(xcred, &ca, GNUTLS_X509_FMT_PEM);
    if (ret < 0) {
        fprintf(stderr, "Zertifikatladen fehlgeschlagen: %s\n", gnutls_strerror(ret));
        return 1;
    }

    gnutls_credentials_set(session, GNUTLS_CRD_CERTIFICATE, xcred);

    // TCP-Verbindung aufbauen
    int sockfd = tcp_connect("weptech-iot.de", "443");
    if (sockfd < 0) {
        fprintf(stderr, "TCP-Verbindung fehlgeschlagen\n");
        return 1;
    }

    gnutls_transport_set_int(session, sockfd);

    // TLS-Handshake
    ret = gnutls_handshake(session);
    if (ret < 0) {
        fprintf(stderr, "❌ TLS-Handshake fehlgeschlagen: %s\n", gnutls_strerror(ret));
        gnutls_deinit(session);
        close(sockfd);
        return 1;
    }

    printf("✅ TLS-Handshake erfolgreich mit: %s\n", gnutls_session_get_desc(session));

    // Aufräumen
    gnutls_bye(session, GNUTLS_SHUT_RDWR);
    gnutls_deinit(session);
    gnutls_certificate_free_credentials(xcred);
    gnutls_global_deinit();
    close(sockfd);

    return 0;
}
