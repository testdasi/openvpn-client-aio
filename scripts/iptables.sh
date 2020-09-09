#!/bin/bash

#eth0 IP
ETH0_IP="$(ip addr show eth0 | grep 'inet ' | cut -f2 | awk '{ print $2}')"
#IP CIDR range
ETH0_RANGE=${ETH0_IP:(-3)}
#Length of IP (to get network from sipcalc
ETH0_IPLEN=${#ETH0_IP} ; let ETH0_IPLEN-=3
#Use sipcalc to get first IP (.0) of network and sed to clean up resulting string
ETH0_NET0="$(sipcalc $ETH0_IP | grep 'Network address')" ; ETH0_NET0=${ETH0_NET0:(-$ETH0_IPLEN)} ; ETH0_NET0="$(echo $ETH0_NET0 | sed 's/ //g')" ; ETH0_NET0="$(echo $ETH0_NET0 | sed 's/-//g')"
#Network in CIDR format
ETH0_NET="$ETH0_NET0$ETH0_RANGE"
echo "[info] eth0 IP is $ETH0_IP in network $ETH0_NET"

echo '[info] Block everything (unless unblock specifically)'
iptables -P INPUT DROP
iptables -P OUTPUT DROP

echo '[info] Unblock loopback'
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

echo '[info] Unblock tunnel'
iptables -A INPUT -i tun0 -j ACCEPT
iptables -A OUTPUT -o tun0 -j ACCEPT

echo "[info] Unblock $ETH0_NET"
iptables -A INPUT -s $ETH0_NET -d $ETH0_NET -j ACCEPT
iptables -A OUTPUT -s $ETH0_NET -d $ETH0_NET -j ACCEPT

echo "[info] Unblock traffic between $ETH0_NET and host"
iptables -A INPUT -s ${HOST_NETWORK} -d $ETH0_NET -i eth0 -p tcp -j ACCEPT
iptables -A OUTPUT -s $ETH0_NET -d ${HOST_NETWORK} -o eth0 -p tcp -j ACCEPT

echo '[info] Unblock icpm outgoing (pings)'
iptables -A INPUT  -p icmp -m state --state ESTABLISHED,RELATED     -j ACCEPT
iptables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

echo '[info] Unblock OpenVPN outgoing'
iptables -A INPUT  -p udp --sport $OPENVPN_PORT -m state --state ESTABLISHED     -j ACCEPT
iptables -A OUTPUT -p udp --dport $OPENVPN_PORT -m state --state NEW,ESTABLISHED -j ACCEPT

echo '[info] Unblock DNS inbound from eth0'
iptables -A INPUT -i eth0 -p tcp --dport $DNS_PORT -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport $DNS_PORT -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p udp --dport $DNS_PORT -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p udp --sport $DNS_PORT -m state --state ESTABLISHED -j ACCEPT

echo '[info] Unblock dante in bound from eth0'
iptables -A INPUT -i eth0 -p tcp --dport $DANTE_PORT -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport $DANTE_PORT -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

echo '[info] Unblock tinyproxy inbound from eth0'
iptables -A INPUT -i eth0 -p tcp --dport $TINYPROXY_PORT -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport $TINYPROXY_PORT -m state --state ESTABLISHED -j ACCEPT

echo '[info] Unblock torsocks inbound from eth0'
iptables -A INPUT -i eth0 -p tcp --dport $TORSOCKS_PORT -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport $TORSOCKS_PORT -m state --state ESTABLISHED -j ACCEPT

echo '[info] Unblock privoxy inbound from eth0'
iptables -A INPUT -i eth0 -p tcp --dport $PRIVOXY_PORT -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport $PRIVOXY_PORT -m state --state ESTABLISHED -j ACCEPT
