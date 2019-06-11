#!/bin/bash

set -Ee
onerror() {
    echo "Fail to execute: $0 $@ ($?)"
    exit 1
}
# exit 1 on error
trap onerror ERR

# setup firewall before docker does so

start() {
    # delete all containers
    docker rm -f $(docker ps -a -q)

    # create user-defined bridge network
    # @see: https://docs.docker.com/network/network-tutorial-standalone/

    docker network create --driver bridge kknet
    docker network ls
    docker network inspect kknet

    # create new containers

    # setup dns service
    docker run -d \
        -p 127.0.0.1:53:53/udp \
        --name dns \
        --network kknet \
        bind \
        named -g -4 -u bind

    dns4_service_status=$(ip addr show | awk '/inet /' | grep -Po "inet \K\d+\.\d+\.\d+\.\d+" | xargs nmap -T4 -Pn -n -p53 | grep -Po "53/\w+\s+open")
    dns6_service_status=$(ip addr show | awk '/inet6/' | grep -Po "inet6 \K[^/]+" | xargs nmap -T4 -Pn -n -6 -p53 | grep -Po "53/\w+\s+open")
    test -n "$dns4_service_status" || test -n "$dns6_service_status" && \
        echo "DNS is running ..." || \
        echo "Fail to serve DNS!" && exit 1

    netstat -lnp | grep :53 && \
        echo "netstat test OK." || \
        echo "netstat test failed! BIND9 won't work!"
    test $(nmap -T4 -p53 -Pn -n 127.0.0.1 | awk 'NR==6' | cut -d' ' -f2) == "open" && \
        echo "nmap test OK." || \
        echo "nmap test failed! BIND9 won't work!"
    dig @127.0.0.1 +time=1 . NS | \
        grep "^;; SERVER: 127.0.0.1#53(127.0.0.1)$" && \
        echo "dig test OK." || \
        echo "dig test failed! BIND9 won't work!"

    # obtain https certificate
    # @see: https://certbot.eff.org/docs/install.html#running-with-docker
    docker run -it --rm --name certbot \
        -p 127.0.0.1:80:80/tcp \
        -p 127.0.0.1:443:443/tcp \
        -v "/etc/letsencrypt:/etc/letsencrypt" \
        -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
        certbot/certbot certonly

    # setup web service
    docker run -d \
        -p 127.0.0.1:80:80/tcp \
        -p 127.0.0.1:443:443/tcp \
        -p 127.0.0.1:1935:1935/tcp \
        -v "/etc/letsencrypt:/etc/letsencrypt" \
        -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
        --name web \
        --network kknet \
        nginx \
        nginx -g 'daemon off;'
}

finalize() {
    docker rm -f dns
}
