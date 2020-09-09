FROM testdasi/openvpn-client-aio-base:latest-amd64

VOLUME ["/etc/openvpn"]

EXPOSE 53/tcp 53/udp 1080/tcp 8080/tcp 8118/tcp 9050/tcp

ADD config /tmp
ADD scripts /

RUN /bin/bash /install.sh \
    && rm -f /install.sh

ENTRYPOINT ["/entrypoint.sh"]
