#!/bin/bash

#echo '[info] Add route to local LAN'
#echo "add route $HOST_LAN via $HOST_IP"
#ip route add $HOST_LAN via $HOST_IP

echo '[info] Block everything (unless unblock specifically)'
iptables -P INPUT DROP
iptables -P OUTPUT DROP

echo '[info] Unblock tunnel both ways'
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i tun0 -j ACCEPT
iptables -A OUTPUT -o tun0 -j ACCEPT

echo '[info] Unblock OpenVPN Port'
iptables -A INPUT -p udp --dport $OPENVPN_PORT -j ACCEPT
iptables -A INPUT -p udp --sport $OPENVPN_PORT -j ACCEPT
iptables -A OUTPUT -p udp --sport $OPENVPN_PORT -j ACCEPT
iptables -A OUTPUT -p udp --dport $OPENVPN_PORT -j ACCEPT

echo '[info] Unblock DNS inbound from eth0'
iptables -A INPUT -i eth0 -p tcp --dport $DNS_PORT -j ACCEPT
iptables -A INPUT -i eth0 -p udp --dport $DNS_PORT -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport $DNS_PORT -j ACCEPT
iptables -A OUTPUT -o eth0 -p udp --sport $DNS_PORT -j ACCEPT

echo '[info] Unblock dante in bound from eth0'
iptables -A INPUT -i eth0 -p tcp --dport $DANTE_PORT -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport $DANTE_PORT -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

echo '[info] Unblock tinyproxy inbound from eth0'
iptables -A INPUT -i eth0 -p tcp --dport $TINYPROXY_PORT -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport $TINYPROXY_PORT -j ACCEPT

echo '[info] Unblock torsocks inbound from eth0'
iptables -A INPUT -i eth0 -p tcp --dport $TORSOCKS_PORT -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport $TORSOCKS_PORT -j ACCEPT

echo '[info] Unblock privoxy inbound from eth0'
iptables -A INPUT -i eth0 -p tcp --dport $PRIVOXY_PORT -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport $PRIVOXY_PORT -j ACCEPT
