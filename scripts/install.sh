#!/bin/bash

# add various base configs
cd /tmp \
    && mkdir -p /etc/stubby \
    && cp -n ./stubby.yml /etc/stubby/ \
    && mkdir -p /etc/tinyproxy \
    && cp -n ./tinyproxy.conf /etc/tinyproxy/ \
    && cp -n ./danted.conf /etc/

# add tor and privoxy depending on torless tag
if [[ ${TAG} =~ "torless" ]]
then
    cd /tmp \
    && rm -fr ./torrc \
    && rm -fr ./privoxy
    echo "[info] Don't install torsocks and privoxy due to tag ${TAG}"
else
    # install torsocks and privoxy
    apt-get -y update \
    && apt-get -y install torsocks privoxy \
    && mkdir -p /etc/tor \
    && rm -rf /etc/tor/* \
    && mkdir -p /etc/privoxy \
    && rm -rf /etc/privoxy/*
    
    # install config files
    cd /tmp \
    && cp -n ./torrc /etc/tor/ \
    && cp -n ./privoxy /etc/privoxy/config
    
    echo "[info] Installed torsocks and privoxy due to tag ${TAG}"
fi

# clean up
apt-get -y autoremove \
    && apt-get -y autoclean \
    && apt-get -y clean \
    && rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/*

# chmod scripts
chmod +x /*.sh
