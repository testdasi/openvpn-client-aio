ARG FRM='testdasi/openvpn-client-aio-base'
ARG TAG='latest'
ARG DEBIAN_FRONTEND='noninteractive'

FROM ${FRM}:${TAG}
ARG FRM
ARG TAG
ARG BUILD_OPT

ENV DNS_SERVER_PORT 53
ENV SOCKS_PROXY_PORT 9118
ENV HTTP_PROXY_PORT 8118
ENV TOR_SOCKS_PORT 9119
ENV TOR_HTTP_PORT 8119
ENV DNS_SERVERS 127.2.2.2
ENV HOST_NETWORK 192.168.0.1/24

EXPOSE ${DNS_SERVER_PORT}/tcp \
    ${DNS_SERVER_PORT}/udp \
    ${SOCKS_PROXY_PORT}/tcp \
    ${HTTP_PROXY_PORT}/tcp \
    ${TOR_SOCKS_PORT}/tcp \
    ${TOR_HTTP_PORT}/tcp

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
#RUN cp -f /testdasi/scripts-debug/* / && chmod +x /*.sh
#ENTRYPOINT ["tini", "--", "/entrypoint.sh"]

## Final clean up ##
RUN rm -Rf /testdasi

## VEH ##
VOLUME ["/config"]
ENTRYPOINT ["tini", "--", "/static-ubuntu/scripts-openvpn/entrypoint.sh"]
HEALTHCHECK CMD /static-ubuntu/scripts-openvpn/healthcheck.sh
