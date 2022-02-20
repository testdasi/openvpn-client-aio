#!/bin/bash

### DNS and DoT ports are fixed ###
echo '[info] Set various ports to docker variables'
DNS_PORT=${DNS_SERVER_PORT}
DANTE_PORT=${SOCKS_PROXY_PORT}
TINYPROXY_PORT=${HTTP_PROXY_PORT}
TORSOCKS_PORT=${TOR_SOCKS_PORT}
PRIVOXY_PORT=${TOR_HTTP_PORT}
# DoT port is fixed due to TLS protocol
DOT_PORT=853

### static scripts ###
source /static/scripts/set_variables_ovpn_port_proto.sh
source /static/scripts/set_variables_eth0.sh
