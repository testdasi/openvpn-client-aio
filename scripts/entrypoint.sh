#!/bin/bash

### Set various variable values ###
echo ''
echo '[info] Setting variables'
source /set_variables.sh
echo '[info] All variables set'

### Fixing config files ###
echo ''
echo '[info] Fixing configs'
source /fix_config.sh
echo '[info] All configs fixed'

### Stubby DNS-over-TLS ###
echo ''
echo "[info] Run stubby in background on port $DNS_PORT"
stubby -g -C /etc/stubby/stubby.yml
ipnaked=$(dig +short myip.opendns.com @208.67.222.222)
echo "[warn] Your ISP public IP is $ipnaked"

### nftables ###
echo ''
echo '[info] Set up nftables rules'
source /nftables.sh
echo '[info] All rules created'

### OpenVPN ###
echo ''
echo "[info] Setting up OpenVPN tunnel"
source /static/scripts/openvpn.sh
echo '[info] Done'

### Dante SOCKS proxy to VPN ###
echo ''
echo "[info] Run danted in background on port $DANTE_PORT"
danted -D -f /etc/dante/danted.conf

### Tinyproxy HTTP proxy to VPN ###
echo ''
echo "[info] Run tinyproxy in background with no log on port $TINYPROXY_PORT"
tinyproxy -c /etc/tinyproxy/tinyproxy.conf

### Run TOR+Privoxy depending on build ###
if [[ -f "/usr/sbin/tor" ]]; then
    echo ''
    echo '[info] Tor build detected...'
    echo "[info] Run tor as service on port $TORSOCKS_PORT"
    service tor start
    echo "[info] Run privoxy in background on port $PRIVOXY_PORT"
    privoxy /etc/privoxy/config
else
    echo ''
    echo '[info] Torless build detected. Skip running torsocks + privoxy configs.'
fi

### Infinite loop to stop docker from stopping ###
sleep_time=10
crashed=0
while true
do
    echo ''
    echo "[info] Wait $sleep_time seconds before next healthcheck..."
    sleep $sleep_time

    iphiden=$(dig +short myip.opendns.com @208.67.222.222)
    echo "[info] Your VPN public IP is $iphiden"
    
    pidlist=$(pidof openvpn)
    if [ -z "$pidlist" ]
    then
        echo '[warn] openvpn crashed, restarting'
        crashed=$(( $crashed + 1 ))
        source /static/scripts/openvpn.sh
    else
        echo "[info] openvpn PID: $pidlist"
    fi
    
    pidlist=$(pidof stubby)
    if [ -z "$pidlist" ]
    then
        echo '[warn] stubby crashed, restarting'
        crashed=$(( $crashed + 1 ))
        stubby -g -C /root/stubby/stubby.yml
    else
        echo "[info] stubby PID: $pidlist"
    fi
    
    pidlist=$(pidof danted)
    if [ -z "$pidlist" ]
    then
        echo '[warn] danted crashed, restarting'
        crashed=$(( $crashed + 1 ))
        danted -D -f /root/dante/danted.conf
    else
        echo "[info] danted PID: $pidlist"
    fi
    
    pidlist=$(pidof tinyproxy)
    if [ -z "$pidlist" ]
    then
        echo '[warn] tinyproxy crashed, restarting'
        crashed=$(( $crashed + 1 ))
        tinyproxy -c /root/tinyproxy/tinyproxy.conf
    else
        echo "[info] tinyproxy PID: $pidlist"
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
            echo "[info] tor PID: $pidlist"
        fi
        pidlist=$(pidof privoxy)
        if [ -z "$pidlist" ]
        then
            echo '[warn] privoxy crashed, restarting'
            crashed=$(( $crashed + 1 ))
            privoxy /etc/privoxy/config
        else
            echo "[info] privoxy PID: $pidlist"
        fi
    else
        echo '[info] Torless build detected. Skip torsocks + privoxy healthchecks.'
    fi    
done
