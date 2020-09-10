FROM testdasi/openvpn-client-aio-base:latest-amd64

ARG SOCKS_PROXY_PORT=9118
ARG HTTP_PROXY_PORT=8118
ARG TOR_SOCKS_PORT=9119
ARG TOR_HTTP_PORT=8119
ARG DNS_SERVERS=127.0.0.1
ARG HOST_NETWORK=192.168.0.1/24

VOLUME ["/etc/openvpn"]

EXPOSE 53/tcp 53/udp ${SOCKS_PROXY_PORT}/tcp ${HTTP_PROXY_PORT}/tcp ${TOR_SOCKS_PORT}/tcp ${TOR_HTTP_PORT}/tcp

ADD config /tmp
ADD scripts /

RUN /bin/bash /install.sh \
    && rm -f /install.sh

ENTRYPOINT ["/entrypoint.sh"]
