# openvpn-client-aio
An "all-in-one" docker for all your private browsing needs. Built for both Unraid and Raspberry Pi 4 but should work in other Linux amd64 / arm32v7 / arm32v6 / i386 docker environments.

## PULL THE RIGHT TAG!
* I have finally managed to get multi-arch buildx working. LOL. Docker should automatically determine the right architecture to pull.
  * For verison with TOR (and Privoxy) -> pull testdasi/openvpn-client-aio:latest
  * For version without TOR (and Privoxy) -> pull testdasi/openvpn-client-aio:latest-torless

## High-level instructions
* Copy your OpenVPN configuration to the host path that is mapped to */etc/openvpn* (must include openvpn.ovpn + credentials + certs).
* Start docker

## Key features
1. OpenVPN client to connect to your favourite VPN provider. Full freedom with what you want to do with the ovpn file.
1. 2 sets of kill switches. NFT kill switch to block connection when VPN is down. Piping kill switch HTTP proxy -> SOCKS5 proxy -> VPN tun0 / TOR tunnel.
1. Stubby for DNS server to connec to DoT (dns-over-tls) services (ip:53 or 127.2.2.2:5253). Use Google and Cloudflare for best performance.
1. Dante for SOCKS5 proxy to your VPN (ip:9118)
1. Tinyproxy for HTTP proxy to your VPN (ip:8118)
1. Torsocks for SOCKS5 proxy to TOR (ip:9119)
1. Privoxy for HTTP proxy to TOR (ip:8119)

## Bits and bobs
* OpenVPN config files MUST be named openvpn.ovpn. The certs and credentials can be included in the config file or split into separate files. The flexibility is yours.
* Explaining the parameters (the values you see in Usage section are default values)
  * DNS_SERVERS: set to 127.2.2.2 will point to stubby (which in turn points to Google / Cloudflare DoT services). Your DNS queries out of the VPN exit will also be encrypted before arriving at Google / Cloudflare for even more privacy. Change it to other comma-separated IPs (e.g. 1.1.1.1,8.8.8.8) will use normal unencrypted DNS, or perhaps a pihole in the local network.
  * HOST_NETWORK: to enable free flow between host network and the docker (e.g. when using docker bridge network). Otherwise, your proxies will only work from within the docker network. Must be in CIDR format e.g. 192.168.1.0/24
  * DNS_SERVER_PORT: the docker will serve as a DNS server for the local network so everything, including DNS, comes out of the VPN exit.
    * Work best if set to 53 as most things can't handle DNS on other ports. In which case, you have to give the docker its own static IP (i.e. use docker macvlan network) if the host also uses port 53 e.g. if you run a Pihole on the host IP. For Unraid, use Custom : br0 / br1 network (to enable this, go to Settings -> Docker).
    * You will need to set each device DNS to the docker IP.
    * Alternatively, you can set your router DHCP to set DNS to the docker IP.
  * SOCKS/HTTP_PROXY_PORT: use these proxies if you want to exit through your VPN. Point to your docker IP on the respective ports.
  * TOR_SOCKS/HTTP_PORT: use these proxies if you want to exit through TOR. Point to your docker IP on the respective ports.
  * The docker port mappings map host ports to docker ports. The docker ports are determined by the aforementioned PORT variables. So if you change the docker variables, you should also change the port mappings accordingly.
* Choice of DoT (instead of DoH - dns-over-https) was intentional. When OpenVPN connects, it needs to resolve the VPN server domain so a port needs to open briefly. DoH would require opening HTTPS port (443), which shares with normal web-browsing so there's a potential point of leakage albeit only momentarily. DoT uses port 853 pretty much for itself. Of course, you can use IP instead of domain but that would restrict the use cases.
* Based on Debian Buster base image mainly because Raspbian Buster is derived from the same. This allows easier development, testing and building on my end.
  * I originally developed this with iptables kill switch; however, iptables is sort of emulated from nftables in Debian Buster. Hence, I updated to using NFT kill switch instead. Iptables versions are kept in /iptables/* in case we need to revert back in the future.
  * Choices of stubby / dante / tinyproxy / torsocks / privoxy are out of convenience i.e. they are debian packages so no need to compile from source. A very-much-appreciated quality-of-life improvement.

## Usage
    docker run -d \
        --name=<container name> \
        --cap-add=NET_ADMIN \
        -v <path for openvpn config>:/etc/openvpn \
        -e DNS_SERVERS=127.2.2.2 \
        -e HOST_NETWORK=192.168.1.0/24 \
        -p 53:53/tcp \
        -p 53:53/udp \
        -p 9118:9118/tcp \
        -p 8118:8118/tcp \
        -p 9119:9119/tcp \
        -p 8119:8119/tcp \
        -e DNS_SERVER_PORT=53 \
        -e SOCKS_PROXY_PORT=9118 \
        -e HTTP_PROXY_PORT=8118 \
        -e TOR_SOCKS_PORT=9119 \
        -e TOR_HTTP_PORT=8119 \
        testdasi/openvpn-client-aio:<tag>

## Unraid example
    docker run -d \
        --name='OpenVPN-AIO-Client' \
        --cap-add=NET_ADMIN \
        -v '/mnt/user/appdata/openvpn-aio-client':'/etc/openvpn':'rw' \
        -e 'DNS_SERVERS'='127.2.2.2' \
        -e 'HOST_NETWORK'='192.168.1.0/24' \
        -p '8153:53/tcp' \
        -p '8153:53/udp' \
        -p '9118:9118/tcp' \
        -p '8118:8118/tcp' \
        -p '9119:9119/tcp' \
        -p '8119:8119/tcp' \
        -e 'DNS_SERVER_PORT'='53' \
        -e 'SOCKS_PROXY_PORT'='9118' \
        -e 'HTTP_PROXY_PORT'='8118' \
        -e 'TOR_SOCKS_PORT'='9119' \
        -e 'TOR_HTTP_PORT'='8119' \
        --net='bridge' \
        -e TZ="Europe/London" \
        -e HOST_OS="Unraid" \
        'testdasi/openvpn-client-aio:latest' 

## Notes
* I code for fun and my personal uses; hence, these niche functionalties that nobody asks for. ;)
* Tested only with PIA since I can't afford anything else. Theoretically, it should work with any VPN services that support OpenVPN.
* If you like my work, [a donation to my burger fund](https://paypal.me/mersenne) is very much appreciated.

[![Donate](https://raw.githubusercontent.com/testdasi/testdasi-unraid-repo/master/donate-button-small.png)](https://paypal.me/mersenne). 
