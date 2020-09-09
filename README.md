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
1. Dante for SOCKS5 proxy to your VPN (ip:1080)
1. Tinyproxy for HTTP proxy to your VPN (ip:8080)
1. Torsocks for SOCKS5 proxy to TOR (ip:9050)
1. Privoxy for HTTP proxy to TOR (ip:8118)
1. Stubby for dns-over-tls client (ip:53 or 127.2.2.2:5253)

## Usage
    docker run -d \
        -p 53:53 \
        -p 1080:1080 \
        -p 8080:8080 \
        -p 9050:9050 \
        -p 8118:8118 \
        --name=<container name> \
        -v <path for openvpn file>:/etc/openvpn \
        testdasi/openvpn-client-aio-arm

## Notes
* I code for fun and my personal uses; hence, these niche functionalties that nobody asks for. ;)
