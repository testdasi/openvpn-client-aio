#!/bin/bash

echo '[info] Create tunnel device'
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

openvpn --daemon --cd /etc/openvpn --config openvpn.ovpn
echo '[info] Connecting to VPN on port $OPENVPN_PORT...'

iphiden=$(dig +short +time=5 +tries=1 myip.opendns.com @208.67.222.222)
while [[ $iphiden =~ "timed out" ]]
do 
    echo '[info] Connection in progress, wait 10s...'
    sleep 10
    iphiden=$(dig +short +time=5 +tries=1 myip.opendns.com @208.67.222.222)
done
echo "[info] Your VPN public IP is $iphiden"

