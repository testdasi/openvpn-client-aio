# openvpn-client-aio
An "all-in-one" docker for all your private browsing needs.

## PULL THE RIGHT TAG!
* For linux/amd64 (e.g. Unraid) -> pull testdasi/openvpn-client-aio:latest-amd64
* For linux/arm/v7 (e.g. Raspberry Pi4) -> pull testdasi/openvpn-client-aio:latest-rpi4 

## High-level instructions
* Copy your ovpn file to the host path that is mapped to */etc/openvpn* (must include ovpn + credentials + certs)
* Start docker

## Key features
1. OpenVPN client to connect to your favourite VPN provider. Full freedom with what you want to do with the ovpn file.
1. IPtable rules to block connection when VPN is down
1. Dante for SOCKS5 proxy to your VPN (ip:9118)
1. Tinyproxy for HTTP proxy to your VPN (ip:8118)
1. Torsocks for SOCKS5 proxy to TOR (ip:9119)
1. Privoxy for HTTP proxy to TOR (ip:8119)
1. Stubby for dns-over-tls client (ip:53 or 127.2.2.2:5253)

## Usage
    docker run -d \
        --name=<container name> \
        --cap-add=NET_ADMIN \
        -v <path for openvpn file>:/etc/openvpn \
        -p 53:53 \
        -p 9118:9118 \
        -p 8118:8118 \
        -p 9119:9119 \
        -p 8119:8119 \
        -e SOCKS_PROXY_PORT=9118 \
        -e HTTP_PROXY_PORT=8118 \
        -e TOR_SOCKS_PORT=9119 \
        -e TOR_HTTP_PORT=8119 \
        -e DNS_SERVERS=127.0.0.1 \
        -e HOST_NETWORK=192.168.0.1/24 \
        testdasi/openvpn-client-aio-arm

## Notes
* I code for fun and my personal uses; hence, these niche functionalties that nobody asks for. ;)
