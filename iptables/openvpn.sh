#!/bin/bash

echo '[info] Create tunnel device'
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

echo "[info] Allow DnS-over-TLS for openvpn to lookup VPN server"
echo 'nameserver 127.2.2.2' > /etc/resolv.conf
iptables -A INPUT  -p tcp --sport $DOT_PORT -j ACCEPT
iptables -A OUTPUT -p tcp --dport $DOT_PORT -j ACCEPT

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
iptables -D OUTPUT -p tcp --dport $DOT_PORT -j ACCEPT
iptables -D INPUT  -p tcp --sport $DOT_PORT -j ACCEPT

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
    iptables -A OUTPUT -p udp -d ${dns_server_item} --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT  -p udp -s ${dns_server_item} --sport 53 -m state --state ESTABLISHED     -j ACCEPT
    iptables -A OUTPUT -p tcp -d ${dns_server_item} --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT  -p tcp -s ${dns_server_item} --sport 53 -m state --state ESTABLISHED     -j ACCEPT
done
