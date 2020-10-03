#!/bin/bash

pidlist=$(pidof openvpn)
if [ -z "$pidlist" ]
then
    echo '[warn] openvpn crashed, restarting'
    crashed=$(( $crashed + 1 ))
    source /static/scripts/openvpn.sh
else
#    echo "[info] openvpn PID: $pidlist"
fi

pidlist=$(pidof stubby)
if [ -z "$pidlist" ]
then
    echo '[warn] stubby crashed, restarting'
    crashed=$(( $crashed + 1 ))
    stubby -g -C /root/stubby/stubby.yml
else
#    echo "[info] stubby PID: $pidlist"
fi

pidlist=$(pidof danted)
if [ -z "$pidlist" ]
then
    echo '[warn] danted crashed, restarting'
    crashed=$(( $crashed + 1 ))
    danted -D -f /root/dante/danted.conf
else
#    echo "[info] danted PID: $pidlist"
fi

pidlist=$(pidof tinyproxy)
if [ -z "$pidlist" ]
then
    echo '[warn] tinyproxy crashed, restarting'
    crashed=$(( $crashed + 1 ))
    tinyproxy -c /root/tinyproxy/tinyproxy.conf
else
#    echo "[info] tinyproxy PID: $pidlist"
fi

### Run TOR+Privoxy healthcheck depending on build ###
if [[ -f "/usr/sbin/tor" ]]; then
    pidlist=$(pidof tor)
    if [ -z "$pidlist" ]
    then
        echo '[warn] tor crashed, restarting'
        crashed=$(( $crashed + 1 ))
        service tor start
    else
#        echo "[info] tor PID: $pidlist"
    fi
    pidlist=$(pidof privoxy)
    if [ -z "$pidlist" ]
    then
        echo '[warn] privoxy crashed, restarting'
        crashed=$(( $crashed + 1 ))
        privoxy /etc/privoxy/config
    else
#        echo "[info] privoxy PID: $pidlist"
    fi
else
#    echo '[info] Torless build detected. Skip torsocks + privoxy healthchecks.'
fi    

# reset wait time if something crashed, otherwise double the wait time till next healthcheck
if (( $crashed > 0 ))
then
    # sleep_time=$(( $crashed * 10 ))
    crashed=0
    exit 1
else
#    sleep_time=$(( $sleep_time * 2 ))
#    # restrict wait time to within 3600s i.e. 1hr
#    if (( $sleep_time > 3600 ))
#    then
#        sleep_time=3600
#    fi
    exit 0
fi
