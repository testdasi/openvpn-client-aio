#!/bin/bash

DANTE_PORT=${SOCKS_PROXY_PORT}
sed -i "s|internal: eth0 port=1080|internal: eth0 port=$DANTE_PORT|g" '/etc/danted.conf'
echo '[info] danted fixed'

TINYPROXY_PORT=${HTTP_PROXY_PORT}
sed -i "s|Port 8080|Port $TINYPROXY_PORT|g" '/etc/tinyproxy/tinyproxy.conf'
echo '[info] tinyproxy fixed'

TORSOCKS_PORT=${TOR_SOCKS_PORT}
sed -i "s|SOCKSPort 0\.0\.0\.0:9050|SOCKSPort 0\.0\.0\.0:$TORSOCKS_PORT|g" '/etc/tor/torrc'
echo '[info] torsocks fixed'

PRIVOXY_PORT=${TOR_HTTP_PORT}
sed -i "s|listen-address 0\.0\.0\.0:8118|listen-address 0\.0\.0\.0:$PRIVOXY_PORT|g" '/etc/privoxy/config'
sed -i "s|forward-socks5t \/ localhost:9050|forward-socks5t \/ localhost:$TORSOCKS_PORT|g" '/etc/privoxy/config'
echo '[info] privoxy fixed'
