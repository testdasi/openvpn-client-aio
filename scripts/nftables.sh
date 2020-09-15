#!/bin/bash

### Flusing ruleset and add missing route ###
echo '[info] Flusing ruleset'
nft flush ruleset
add_route="$(ip route | grep 'default')" ; add_route="$(sed "s|default|$HOST_NETWORK|g" <<< $add_route)"
ip route add $add_route
echo "[info] Added route $add_route"

### Editing ruleset ###
echo '[info] Editing base ruleset'
rm -f /nftables.rules
cp /ruleset.nft /nftables.rules
sed -i "s|_ETH0_NET_|$ETH0_NET|g" '/nftables.rules'
sed -i "s|_HOST_NETWORK_|${HOST_NETWORK}|g" '/nftables.rules'
sed -i "s|_OPENVPN_PROTO_|$OPENVPN_PROTO|g" '/nftables.rules'
sed -i "s|_OPENVPN_PORT_|$OPENVPN_PORT|g" '/nftables.rules'
sed -i "s|_DNS_PORT_|$DNS_PORT|g" '/nftables.rules'
sed -i "s|_DANTE_PORT_|$DANTE_PORT|g" '/nftables.rules'
sed -i "s|_TINYPROXY_PORT_|$TINYPROXY_PORT|g" '/nftables.rules'

### Run TOR+Privoxy depending on build ###
if [[ -f "/usr/sbin/tor" ]]; then
    echo '[info] Tor build detected. Editing tor + privoxy ruleset'
    sed -i "s|_TORSOCKS_PORT_|$TORSOCKS_PORT|g" '/nftables.rules'
    sed -i "s|_PRIVOXY_PORT_|$PRIVOXY_PORT|g" '/nftables.rules'
else
    echo '[info] Torless build detected. Removing tor + privoxy ruleset'
    sed -i 's|add rule ip filter INPUT iifname "eth0" tcp dport _TORSOCKS_PORT_ ct state new,established counter accept||g' '/nftables.rules'
    sed -i 's|add rule ip filter INPUT iifname "eth0" tcp dport _PRIVOXY_PORT_ ct state new,established counter accept||g' '/nftables.rules'
    sed -i 's|add rule ip filter OUTPUT oifname "eth0" tcp sport _TORSOCKS_PORT_ ct state established counter accept||g' '/nftables.rules'
    sed -i 's|add rule ip filter OUTPUT oifname "eth0" tcp sport _PRIVOXY_PORT_ ct state established counter accept||g' '/nftables.rules'
fi

### Add rules ###
echo '[info] Apply rules'
nft -f /nftables.rules
rm /nftables.rules
