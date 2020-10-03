#!/bin/bash

# install static files
mkdir -p /temp \
    && cd /temp \
    && curl -L "https://github.com/testdasi/static/archive/master.zip" -o /temp/static.zip \
    && unzip /temp/static.zip \
    && rm -f /temp/static.zip \
    && mv /temp/static-master /static

# add tor and privoxy depending on torless tag
if [[ ${BUILD_OPT} =~ "torless" ]]
then
    cd /tmp \
    && rm -fr ./torrc \
    && rm -fr ./privoxy
    echo "[info] Don't install torsocks and privoxy due to build option ${BUILD_OPT}"
else
    # install torsocks and privoxy
    apt-get -y update \
    && apt-get -y install torsocks privoxy \
    && apt-get -y install tini \
    && mkdir -p /etc/tor \
    && rm -rf /etc/tor/* \
    && mkdir -p /etc/privoxy \
    && rm -rf /etc/privoxy/*
    
    # install config files
    cd /tmp \
    && cp -n ./torrc /etc/tor/ \
    && cp -n ./privoxy /etc/privoxy/config
    
    echo "[info] Installed torsocks and privoxy due to build option ${BUILD_OPT}"
fi

# clean up
apt-get -y autoremove \
    && apt-get -y autoclean \
    && apt-get -y clean \
    && rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/*

# chmod scripts
chmod +x /*.sh
