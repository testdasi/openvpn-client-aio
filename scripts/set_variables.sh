#!/bin/bash

### DNS and DoT ports are fixed ###
echo '[info] Set DNS ports'
DNS_PORT=53
DOT_PORT=853

### Dynamically determine OpenVPN port and protocol ###
echo '[info] Determine openvpn port from config file'
OPENVPN_PORT=$(grep -m 1 "remote " /etc/openvpn/openvpn.ovpn) ; OPENVPN_PORT=${OPENVPN_PORT:(-5)} ; OPENVPN_PORT="$(echo $OPENVPN_PORT | sed 's/ //g')"
echo '[info] Determine openvpn protocol from config file'
OPENVPN_PROTO=$(grep -m 1 "proto " /etc/openvpn/openvpn.ovpn) ; OPENVPN_PROTO="$(echo $OPENVPN_PROTO | sed 's/proto //g')"
echo "[info] port=$OPENVPN_PORT proto=$OPENVPN_PROTO"

### Dynamically determine eth0 network for iptables ###
echo '[info] Determine eth0 network for iptables'
#eth0 IP
ETH0_IP="$(ip addr show eth0 | grep 'inet ' | cut -f2 | awk '{ print $2}')"
#IP CIDR range
ETH0_RANGE=${ETH0_IP:(-3)}
#Length of IP (to derive network from sipcalc)
ETH0_IPLEN=${#ETH0_IP} ; let ETH0_IPLEN-=3
#Use sipcalc to get first IP (.0) of network and sed to clean up resulting string when eth0 IP longer than first IP e.g. .100 vs .0
ETH0_NET0="$(sipcalc $ETH0_IP | grep 'Network address')" ; ETH0_NET0=${ETH0_NET0:(-$ETH0_IPLEN)} ; ETH0_NET0="$(echo $ETH0_NET0 | sed 's/ //g')" ; ETH0_NET0="$(echo $ETH0_NET0 | sed 's/-//g')"
#Network in CIDR format
ETH0_NET="$ETH0_NET0$ETH0_RANGE"
echo "[info] eth0 IP is $ETH0_IP in network $ETH0_NET"
