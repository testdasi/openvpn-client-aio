#!/bin/bash

### Only run process if ovpn found ###
if [[ -f "/etc/openvpn/openvpn.ovpn" ]]
then
    echo '[info] Config file detected...'
    ### Set various variable values ###
    echo ''
    echo '[info] Setting variables'
    source /set_variables.sh
    echo '[info] All variables set'

    ### Fixing config files ###
    echo ''
    echo '[info] Fixing configs'
    source /fix_config.sh
    echo '[info] All configs fixed'

    ### Stubby DNS-over-TLS ###
    echo ''
    echo "[info] Run stubby in background on port $DNS_PORT"
    stubby -g -C /etc/stubby/stubby.yml
    ipnaked=$(dig +short myip.opendns.com @208.67.222.222)
    echo "[warn] Your ISP public IP is $ipnaked"

    ### nftables ###
    echo ''
    echo '[info] Set up nftables rules'
    source /nftables.sh
    echo '[info] All rules created'

    ### OpenVPN ###
    echo ''
    echo "[info] Setting up OpenVPN tunnel"
    source /static/scripts/openvpn.sh
    echo '[info] Done'

    ### Dante SOCKS proxy to VPN ###
    echo ''
    echo "[info] Run danted in background on port $DANTE_PORT"
    danted -D -f /etc/dante/danted.conf

    ### Tinyproxy HTTP proxy to VPN ###
    echo ''
    echo "[info] Run tinyproxy in background with no log on port $TINYPROXY_PORT"
    tinyproxy -c /etc/tinyproxy/tinyproxy.conf

    ### Run TOR+Privoxy depending on build ###
    if [[ -f "/usr/sbin/tor" ]]; then
        echo ''
        echo '[info] Tor build detected...'
        echo "[info] Run tor as service on port $TORSOCKS_PORT"
        service tor start
        echo "[info] Run privoxy in background on port $PRIVOXY_PORT"
        privoxy /etc/privoxy/config
    else
        echo ''
        echo '[info] Torless build detected. Skip running torsocks + privoxy configs.'
    fi
    
    wait -n

    ### Infinite loop to stop docker from stopping ###
#    sleep_time=3600
#    crashed=0
#    while true
#    do
#        echo ''
#        echo "[info] Wait $sleep_time seconds before next healthcheck..."
#        sleep $sleep_time

#        iphiden=$(dig +short myip.opendns.com @208.67.222.222)
#        echo "[info] Your VPN public IP is $iphiden"
#
#    done
else
    echo '[CRITICAL] Config file not found, quitting...'
fi
