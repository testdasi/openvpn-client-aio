ARG TAG=latest
FROM testdasi/openvpn-client-aio-base:$TAG

ENV DNS_SERVER_PORT 53
ENV SOCKS_PROXY_PORT 9118
ENV HTTP_PROXY_PORT 8118
ENV TOR_SOCKS_PORT 9119
ENV TOR_HTTP_PORT 8119
ENV DNS_SERVERS 127.2.2.2
ENV HOST_NETWORK 192.168.0.1/24

EXPOSE ${DNS_SERVER_PORT}/tcp ${DNS_SERVER_PORT}/udp ${SOCKS_PROXY_PORT}/tcp ${HTTP_PROXY_PORT}/tcp ${TOR_SOCKS_PORT}/tcp ${TOR_HTTP_PORT}/tcp

ADD config /tmp
ADD scripts /

RUN /bin/bash /install.sh \
    && rm -f /install.sh

VOLUME ["/etc/openvpn"]

ENTRYPOINT ["/entrypoint.sh"]

RUN echo "$(date "+%d.%m.%Y %T")" >> /build_date.info
