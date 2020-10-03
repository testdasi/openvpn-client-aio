#!/bin/bash

crashed=0

pidlist=$(pidof openvpn)
if [ -z "$pidlist" ]
then
    echo '[warn] openvpn crashed, restarting'
    crashed=$(( $crashed + 1 ))
    source /static/scripts/openvpn.sh
fi

pidlist=$(pidof stubby)
if [ -z "$pidlist" ]
then
    echo '[warn] stubby crashed, restarting'
    crashed=$(( $crashed + 1 ))
    stubby -g -C /root/stubby/stubby.yml
fi

pidlist=$(pidof danted)
if [ -z "$pidlist" ]
then
    echo '[warn] danted crashed, restarting'
    crashed=$(( $crashed + 1 ))
    danted -D -f /root/dante/danted.conf
fi

pidlist=$(pidof tinyproxy)
if [ -z "$pidlist" ]
then
    echo '[warn] tinyproxy crashed, restarting'
    crashed=$(( $crashed + 1 ))
    tinyproxy -c /root/tinyproxy/tinyproxy.conf
fi

### Run TOR+Privoxy healthcheck depending on build ###
if [[ -f "/usr/sbin/tor" ]]; then
    pidlist=$(pidof tor)
    if [ -z "$pidlist" ]
    then
        echo '[warn] tor crashed, restarting'
        crashed=$(( $crashed + 1 ))
        service tor start
    fi
    pidlist=$(pidof privoxy)
    if [ -z "$pidlist" ]
    then
        echo '[warn] privoxy crashed, restarting'
        crashed=$(( $crashed + 1 ))
        privoxy /etc/privoxy/config
    fi
fi    

# reset wait time if something crashed, otherwise double the wait time till next healthcheck
if (( $crashed > 0 ))
then
    exit 1
else
    exit 0
fi
