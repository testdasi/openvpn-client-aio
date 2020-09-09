#!/bin/bash

ETH0_IP="$(ip addr show eth0 | grep 'inet ' | cut -f2 | awk '{ print $2}')"
ETH0_RANGE=${ETH0_NET:(-3)}
ETH0_NET="$(sipcalc $ETH0_IP | grep 'Network address')"
ETH0_NET=${ETH0_NET:(-15)}
ETH0_NET="$(echo $ETH0_NET | sed 's/ //g')"
ETH0_NET="$(echo $ETH0_NET | sed 's/-//g')"
echo "[info] $ETH0_IP is in $ETH0_NET$ETH0_RANGE"

echo '[info] Block everything (unless unblock specifically)'
iptables -P INPUT DROP
iptables -P OUTPUT DROP

echo '[info] Unblock loopback'
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

echo '[info] Unblock tunnel'
iptables -A INPUT -i tun0 -j ACCEPT
iptables -A OUTPUT -o tun0 -j ACCEPT

echo '[info] Unblock internal comm'
-A INPUT -s 172.71.1.0/24 -d 172.71.1.0/24 -j ACCEPT
-A INPUT -s 10.132.6.0/23 -d 10.132.6.0/23 -j ACCEPT
-A INPUT -s 10.132.6.0/23 -d 172.71.1.0/24 -i eth0 -p tcp -j ACCEPT
-A INPUT -s 10.132.6.0/23 -d 10.132.6.0/23 -i eth0 -p tcp -j ACCEPT

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
