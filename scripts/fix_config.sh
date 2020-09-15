#!/bin/bash

sed -i "s|  - 0\.0\.0\.0\@53|  - 0\.0\.0\.0\@$DNS_PORT|g" '/etc/stubby/stubby.yml'
echo '[info] stubby fixed.'

sed -i "s|internal: eth0 port=1080|internal: eth0 port=$DANTE_PORT|g" '/etc/danted.conf'
echo '[info] danted fixed.'

sed -i "s|Port 8080|Port $TINYPROXY_PORT|g" '/etc/tinyproxy/tinyproxy.conf'
sed -i "s|upstream socks5 localhost:1080|upstream socks5 $ETH0_IP:$DANTE_PORT|g" '/etc/tinyproxy/tinyproxy.conf'
echo '[info] tinyproxy fixed.'

### Fix TOR+Privoxy depending on build ###
if [[ -f "/usr/sbin/tor" ]]; then
    echo '[info] Tor build detected...'
    sed -i "s|SOCKSPort 0\.0\.0\.0:9050|SOCKSPort 0\.0\.0\.0:$TORSOCKS_PORT|g" '/etc/tor/torrc'
    echo '[info] torsocks fixed.'
    sed -i "s|listen-address 0\.0\.0\.0:8118|listen-address 0\.0\.0\.0:$PRIVOXY_PORT|g" '/etc/privoxy/config'
    sed -i "s|forward-socks5t \/ localhost:9050|forward-socks5t \/ localhost:$TORSOCKS_PORT|g" '/etc/privoxy/config'
    echo '[info] privoxy fixed.'
else
    echo '[info] Torless build detected. Skip fixing torsocks + privoxy configs.'
fi


