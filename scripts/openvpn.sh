#!/bin/bash

echo '[info] Create tunnel device'
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

openvpn --daemon --cd /etc/openvpn --config openvpn.ovpn
echo "[info] Connecting to VPN on port $OPENVPN_PORT..."

iphiden=$(dig +short +time=5 +tries=1 myip.opendns.com @208.67.222.222)
while [[ $iphiden =~ "timed out" ]]
do 
    echo '[info] Connection in progress, wait 10s...'
    sleep 10
    iphiden=$(dig +short +time=5 +tries=1 myip.opendns.com @208.67.222.222)
done
echo "[info] Your VPN public IP is $iphiden"

echo "[info] Change DNS servers to ${DNS_SERVERS}"
# split comma seperated string into list from DNS_SERVERS env variable
IFS=',' read -ra name_server_list <<< "${DNS_SERVERS}"
# remove existing dns, docker injects dns from host and isp dns can block/hijack
> /etc/resolv.conf
# process name servers in the list
for name_server_item in "${name_server_list[@]}"; do
	# strip whitespace from start and end of name_server_item
	name_server_item=$(echo "${name_server_item}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')
	echo "[info] Adding ${name_server_item} to /etc/resolv.conf"
	echo "nameserver ${name_server_item}" >> /etc/resolv.conf
done
