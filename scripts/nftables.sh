#!/bin/bash

### Clean existing nftable rules ###
#FAMILIES="ip ip6 arp bridge"
#for FAMILY in $FAMILIES; do
#    TABLES=$($nft list tables $FAMILY | grep "^table\s" | cut -d' ' -f2)
#    for TABLE in $TABLES; do
#        CHAINS=$($nft list table $FAMILY $TABLE | grep "^\schain\s" | cut -d' ' -f2)
#        for CHAIN in $CHAINS; do
#            echo "[info] Flushing chain: $FAMILY->$TABLE->$CHAIN"
#            $nft flush chain $FAMILY $TABLE $CHAIN
#            $nft delete chain $FAMILY $TABLE $CHAIN
#        done
#        echo "[info] Flushing table: $FAMILY->$TABLE"
#        $nft flush table $FAMILY $TABLE
#        $nft delete table $FAMILY $TABLE
#    done
#done
nft flush ruleset

### Editing ruleset ###
echo '[info] Editing ruleset'
cp /ruleset.nft /nftables.rules
sed -i "s|_ETH0_NET_|$ETH0_NET|g" '/nftables.rules'
sed -i "s|_HOST_NETWORK_|${HOST_NETWORK}|g" '/nftables.rules'
sed -i "s|_OPENVPN_PROTO_|$OPENVPN_PROTO|g" '/nftables.rules'
sed -i "s|_OPENVPN_PORT_|$OPENVPN_PORT|g" '/nftables.rules'
sed -i "s|_DNS_PORT_|$DNS_PORT|g" '/nftables.rules'
sed -i "s|_DANTE_PORT_|$DANTE_PORT|g" '/nftables.rules'
sed -i "s|_TINYPROXY_PORT_|$TINYPROXY_PORT|g" '/nftables.rules'
sed -i "s|_TORSOCKS_PORT_|$TORSOCKS_PORT|g" '/nftables.rules'
sed -i "s|_PRIVOXY_PORT_|$PRIVOXY_PORT|g" '/nftables.rules'

### Add rules ###
echo '[info] Apply rules'
cd / && nft -fe nftables.rules
#rm /nftables.rules
