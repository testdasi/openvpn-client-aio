#!/bin/bash

echo '[info] Create tunnel device'
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

echo "[info] Allow DnS-over-TLS for openvpn to lookup VPN server"
echo 'nameserver 127.2.2.2' > /etc/resolv.conf
nft add rule ip filter INPUT  tcp sport $DOT_PORT counter accept
nft add rule ip filter OUTPUT tcp dport $DOT_PORT counter accept

echo "[info] Connecting to VPN on port $OPENVPN_PORT with proto $OPENVPN_PROTO..."
openvpn --daemon --cd /etc/openvpn --config openvpn.ovpn
iphiden=$(dig +short +time=5 +tries=1 myip.opendns.com @208.67.222.222)
while [[ $iphiden =~ "timed out" ]]
do 
    echo '[info] Connection in progress, wait 10s...'
    sleep 10
    iphiden=$(dig +short +time=5 +tries=1 myip.opendns.com @208.67.222.222)
done
echo "[info] Your VPN public IP is $iphiden"

echo "[info] Block DnS-over-TLS to force traffic through tunnel"
rulehandle="$(nft list table filter -a | grep "tcp sport $DOT_PORT")" ; rulehandle=${rulehandle:(-2)}
nft delete rule filter INPUT handle $rulehandle
rulehandle="$(nft list table filter -a | grep "tcp dport $DOT_PORT")" ; rulehandle=${rulehandle:(-2)}
nft delete rule filter OUTPUT handle $rulehandle

echo "[info] Change DNS servers to ${DNS_SERVERS}"
# split comma seperated string into list from DNS_SERVERS env variable
IFS=',' read -ra dns_server_list <<< "${DNS_SERVERS}"
# remove existing dns, docker injects dns from host and isp dns can block/hijack
> /etc/resolv.conf
# process name servers in the list
for dns_server_item in "${dns_server_list[@]}"; do
    # strip whitespace from start and end of dns_server_item
    dns_server_item=$(echo "${dns_server_item}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')
    
    echo "[info] Adding ${dns_server_item} to /etc/resolv.conf"
    echo "nameserver ${dns_server_item}" >> /etc/resolv.conf
    
    #resolv.conf only supports port 53
    echo "[info] Allowing DNS lookups (tcp, udp port 53) to server '${dns_server_item}'"
    nft add rule ip filter INPUT  ip saddr ${dns_server_item} tcp sport 53 ct state established     counter accept
    nft add rule ip filter OUTPUT ip daddr ${dns_server_item} tcp dport 53 ct state new,established counter accept
    nft add rule ip filter INPUT  ip saddr ${dns_server_item} udp sport 53 ct state established     counter accept
    nft add rule ip filter OUTPUT ip daddr ${dns_server_item} udp dport 53 ct state new,established counter accept
done
