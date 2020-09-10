#!/bin/bash

### Dynamically determine OpenVPN port and protocol ###
echo '[info] Determine openvpn port from config file'
OPENVPN_PORT=$(grep -m 1 "remote " /etc/openvpn/openvpn.ovpn)
OPENVPN_PORT=${OPENVPN_PORT:(-5)}
echo '[info] Determine openvpn protocol from config file'
OPENVPN_PROTO=$(grep -m 1 "proto " /etc/openvpn/openvpn.ovpn)
OPENVPN_PROTO="$(echo $OPENVPN_PROTO | sed 's/proto //g')"
echo "[info] port=$OPENVPN_PORT proto=$OPENVPN_PROTO"

### Fixing config files ###
echo ''
echo '[info] Fixing configs'
source /fix_config.sh
echo '[info] All configs fixed'

### Stubby DNS-over-TLS ###
echo ''
DNS_PORT=53
DOT_PORT=853
echo "[info] Run stubby in background on port $DNS_PORT"
stubby -g -C /etc/stubby/stubby.yml
ipnaked=$(dig +short myip.opendns.com @208.67.222.222)
echo "[warn] Your ISP public IP is $ipnaked"

### IPtable ###
echo ''
echo '[info] Set up IP tables'
source /iptables.sh
echo '[info] All rules created'
ipttest=$(dig +short +time=5 +tries=1 myip.opendns.com @208.67.222.222)
echo "[info] Quick block test. Expected result is time out. Actual result is $ipttest"

### OpenVPN ###
echo ''
echo "[info] Setting up OpenVPN tunnel"
source /openvpn.sh
echo '[info] Done'

### Dante SOCKS proxy to VPN ###
echo ''
echo "[info] Run danted in background on port $DANTE_PORT"
danted -D -f /etc/danted.conf

### Tinyproxy HTTP proxy to VPN ###
echo ''
echo "[info] Run tinyproxy in background with no log on port $TINYPROXY_PORT"
tinyproxy -c /etc/tinyproxy/tinyproxy.conf

### TOR socks proxy ###
echo ''
echo "[info] Run tor as service on port $TORSOCKS_PORT"
service tor start

### Privoxy HTTP proxy to TOR ###
echo ''
echo "[info] Run privoxy in background on port $PRIVOXY_PORT"
privoxy /etc/privoxy/config

### Infinite loop to stop docker from stopping ###
while true
do
    echo ''
    iphiden=$(dig +short myip.opendns.com @208.67.222.222)
    echo "[info] Your VPN public IP is $iphiden"
    pidlist=$(pidof openvpn)
    echo "[info] OpenVPN PID: $pidlist"
    pidlist=$(pidof stubby)
    echo "[info] stubby PID: $pidlist"
    pidlist=$(pidof danted)
    echo "[info] danted PID: $pidlist"
    pidlist=$(pidof tinyproxy)
    echo "[info] tinyproxy PID: $pidlist"
    pidlist=$(pidof tor)
    echo "[info] tor PID: $pidlist"
    pidlist=$(pidof privoxy)
    echo "[info] privoxy PID: $pidlist"
    sleep 3600s
done
