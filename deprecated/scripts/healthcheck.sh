#!/bin/bash

### Autoheal ###
crashed=0

pidlist=$(pidof stubby)
if [ -z "$pidlist" ]
then
    crashed=$(( $crashed + 1 ))
    stubby -g -C /etc/stubby/stubby.yml
fi

pidlist=$(pidof danted)
if [ -z "$pidlist" ]
then
    crashed=$(( $crashed + 1 ))
    danted -D -f /etc/dante/danted.conf
fi

pidlist=$(pidof tinyproxy)
if [ -z "$pidlist" ]
then
    crashed=$(( $crashed + 1 ))
    tinyproxy -c /etc/tinyproxy/tinyproxy.conf
fi

if [[ -f "/usr/sbin/tor" ]]; then
    pidlist=$(pidof tor)
    if [ -z "$pidlist" ]
    then
        crashed=$(( $crashed + 1 ))
        service tor start
    fi
    pidlist=$(pidof privoxy)
    if [ -z "$pidlist" ]
    then
        crashed=$(( $crashed + 1 ))
        privoxy /etc/privoxy/config
    fi
fi    

### Critical check ###
pidlist=$(pidof openvpn)
if [ -z "$pidlist" ]
then
    # kill the docker (by killing init script) if openvpn crashed
    pidentry=$(pgrep entrypoint.sh)
    kill $pidentry
    exit 1
else
    # return exit code for healthcheck
    if (( $crashed > 0 ))
    then
        exit 1
    else
        exit 0
    fi
fi
