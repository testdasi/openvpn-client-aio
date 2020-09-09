#!/bin/bash

### Fixed DNS Port ###
DNS_PORT=53

### Dynamically determine OPENVPN_PORT based on config file ###
#OPENVPN_PORT=1198
OPENVPN_PORT=$(grep -m 1 "remote " /etc/openvpn/openvpn.ovpn)
OPENVPN_PORT=${OPENVPN_PORT:(-5)}

### Adjusting config with actual port ###
echo '[info] Fixing configs'
DANTE_PORT=1080
sed -i "s|internal: eth0 port=1080|internal: eth0 port=$DANTE_PORT|g" '/etc/danted.conf'
TINYPROXY_PORT=8080
sed -i "s|Port 8080|Port $TINYPROXY_PORT|g" '/etc/tinyproxy/tinyproxy.conf'
TORSOCKS_PORT=9050
sed -i "s|SOCKSPort 0\.0\.0\.0:9050|SOCKSPort 0\.0\.0\.0:$TORSOCKS_PORT|g" '/etc/tor/torrc'
PRIVOXY_PORT=8118
sed -i "s|listen-address 0\.0\.0\.0:8118|listen-address 0\.0\.0\.0:$PRIVOXY_PORT|g" '/etc/privoxy/config'
echo '[info] All configs fixed'

### Stubby DNS-over-TLS ###
echo ''
echo "[info] Run stubby in background on port $DNS_PORT"
stubby -g -C /etc/stubby/stubby.yml
ipnaked=$(dig +short myip.opendns.com @208.67.222.222)
echo "[warn] Your ISP public IP is $ipnaked"

### IP Tables ###
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
echo '[info] Connected!'

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
