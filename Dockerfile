ARG FRM='testdasi/openvpn-client-aio-base'
ARG TAG='latest'
ARG DEBIAN_FRONTEND='noninteractive'

FROM ${FRM}:${TAG}
ARG FRM
ARG TAG
ARG BUILD_OPT
ARG TARGETPLATFORM

ENV LAUNCHER_GUI_PORT=8000
ENV DNS_SERVER_PORT=53
ENV SOCKS_PROXY_PORT=9118
ENV HTTP_PROXY_PORT=8118
ENV TOR_SOCKS_PORT=9119
ENV TOR_HTTP_PORT=8119
ENV USENET_HTTP_PORT=8080
ENV USENET_HTTPS_PORT=8090
ENV TORRENT_GUI_PORT=3000
ENV SEARCHER_GUI_PORT=5076
ENV TORZNAB_PORT=9117
ENV DNS_SERVERS=127.2.2.2
ENV HOST_NETWORK=192.168.0.1/24
ENV SERVER_IP=192.168.1.2

EXPOSE ${LAUNCHER_GUI_PORT}/tcp \
    ${DNS_SERVER_PORT}/tcp \
    ${DNS_SERVER_PORT}/udp \
    ${SOCKS_PROXY_PORT}/tcp \
    ${HTTP_PROXY_PORT}/tcp \
    ${TOR_SOCKS_PORT}/tcp \
    ${TOR_HTTP_PORT}/tcp \
    ${USENET_HTTP_PORT}/tcp \
    ${USENET_HTTPS_PORT}/tcp \
    ${TORRENT_GUI_PORT}/tcp \
    ${SEARCHER_GUI_PORT}/tcp \
    ${TORZNAB_PORT}/tcp

## build note ##
RUN echo "$(date "+%d.%m.%Y %T") Built from ${FRM}:${TAG}" >> /build.info

## install static codes ##
RUN rm -Rf /testdasi \
    && mkdir -p /temp \
    && cd /temp \
    && curl -sL "https://github.com/testdasi/static-ubuntu/archive/main.zip" -o /temp/temp.zip \
    && unzip /temp/temp.zip \
    && rm -f /temp/temp.zip \
    && mv /temp/static-ubuntu-main /testdasi \
    && rm -Rf /testdasi/deprecated

## execute execute execute ##
RUN /bin/bash /testdasi/scripts-install/install-openvpn-client-aio.sh

## debug mode (comment to disable) ##
#RUN /bin/bash /testdasi/scripts-install/install-debug-mode.sh
#ENTRYPOINT ["tini", "--", "/entrypoint.sh"]

## Final clean up ##
RUN rm -Rf /testdasi

## VEH ##
VOLUME ["/config"]
ENTRYPOINT ["tini", "--", "/static-ubuntu/openvpn-client/entrypoint.sh"]
HEALTHCHECK CMD /static-ubuntu/openvpn-client/healthcheck.sh
