ARG FRM='testdasi/openvpn-client-aio-base'
ARG TAG='latest'

FROM $FRM:$TAG

ARG DNS_SERVER_PORT=53
ARG SOCKS_PROXY_PORT=9118
ARG HTTP_PROXY_PORT=8118
ARG TOR_SOCKS_PORT=9119
ARG TOR_HTTP_PORT=8119
ARG DNS_SERVERS=127.2.2.2
ARG HOST_NETWORK=192.168.0.1/24

EXPOSE ${DNS_SERVER_PORT}/tcp ${DNS_SERVER_PORT}/udp ${SOCKS_PROXY_PORT}/tcp ${HTTP_PROXY_PORT}/tcp ${TOR_SOCKS_PORT}/tcp ${TOR_HTTP_PORT}/tcp

ADD config /tmp
ADD scripts /

RUN /bin/bash /install.sh \
    && rm -f /install.sh

VOLUME ["/etc/openvpn"]

RUN echo "$(date "+%d.%m.%Y %T") Successfully built from $FRM:$TAG" >> build_date.info

ENTRYPOINT ["/entrypoint.sh"]
