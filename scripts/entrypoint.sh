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

### IPtables ###
echo ''
echo '[info] Set up iptables rules'
source /iptables.sh
echo '[info] All rules created'

### Quick block test ####
echo ''
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

### Create nft ruleset for reference ###
echo ''
echo '[info] Creating iptables and nft ruleset files for reference'
iptables-save > /ruleset.ipt ; iptables-restore-translate -f /ruleset.ipt > /ruleset.nft

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
