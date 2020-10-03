#!/bin/bash

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

### static scripts ###
source /static/scripts/fix_config_stubby.sh
source /static/scripts/fix_config_dante.sh
source /static/scripts/fix_config_tinyproxy.sh
