#!/bin/bash

echo '[info] Create tunnel device'
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

echo "[info] Allow DnS-over-TLS for openvpn to lookup VPN server"
#iptables -A INPUT  -p tcp --sport $DOT_PORT -m state --state ESTABLISHED     -j ACCEPT
#iptables -A OUTPUT -p tcp --dport $DOT_PORT -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -A INPUT -s 1.1.1.1 -d $ETH0_NET -j ACCEPT
#iptables -A OUTPUT -s $ETH0_NET -d 1.1.1.1 -j ACCEPT
nft add rule ip filter INPUT udp sport $DOT_PORT counter accept
nft add rule ip filter OUTPUT udp dport $DOT_PORT counter accept
echo 'nameserver 127.2.2.2' >> /etc/resolv.conf

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
#iptables -D OUTPUT -p tcp --dport $DOT_PORT -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -D INPUT  -p tcp --sport $DOT_PORT -m state --state ESTABLISHED     -j ACCEPT
#iptables -D INPUT -s 1.1.1.1 -d $ETH0_NET -j ACCEPT
#iptables -D OUTPUT -s $ETH0_NET -d 1.1.1.1 -j ACCEPT
### NEED TO FIND RULE HANDLE TO DELETE ###
#nft delete rule filter INPUT handle 5
#nft delete rule filter OUTPUT handle 5

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
    #iptables -A OUTPUT -p udp -d ${dns_server_item} --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
    #iptables -A INPUT  -p udp -s ${dns_server_item} --sport 53 -m state --state ESTABLISHED     -j ACCEPT
    #iptables -A OUTPUT -p tcp -d ${dns_server_item} --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
    #iptables -A INPUT  -p tcp -s ${dns_server_item} --sport 53 -m state --state ESTABLISHED     -j ACCEPT
    nft add rule ip filter INPUT ip saddr ${dns_server_item} udp sport 53 ct state established  counter accept
    nft add rule ip filter INPUT ip saddr ${dns_server_item} tcp sport 53 ct state established  counter accept
    nft add rule ip filter OUTPUT ip daddr ${dns_server_item} udp dport 53 ct state new,established  counter accept
    nft add rule ip filter OUTPUT ip daddr ${dns_server_item} tcp dport 53 ct state new,established  counter accept
done
