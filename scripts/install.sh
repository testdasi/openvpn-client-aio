#!/bin/bash

# add various configs
cd /tmp \
    && mkdir -p /etc/stubby \
    && cp -n ./stubby.yml /etc/stubby/ \
    && mkdir -p /etc/tinyproxy \
    && cp -n ./tinyproxy.conf /etc/tinyproxy/ \
    && mkdir -p /etc/tor \
    && cp -n ./torrc /etc/tor/ \
    && mkdir -p /etc/privoxy \
    && cp -n ./privoxy /etc/privoxy/config \
    && cp -n ./danted.conf /etc

# clean up
apt-get -y autoremove \
    && apt-get -y autoclean \
    && apt-get -y clean \
    && rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/*

# chmod scripts
chmod +x /*.sh
