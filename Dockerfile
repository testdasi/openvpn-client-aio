FROM testdasi/openvpn-client-aio-base:latest-amd64

VOLUME ["/etc/openvpn"]

EXPOSE 53/tcp 53/udp ${SOCKS_PROXY_PORT}/tcp ${HTTP_PROXY_PORT}/tcp ${TOR_SOCKS_PORT}/tcp ${TOR_HTTP_PORT}/tcp

ADD config /tmp
ADD scripts /

RUN /bin/bash /install.sh \
    && rm -f /install.sh

ENTRYPOINT ["/entrypoint.sh"]
