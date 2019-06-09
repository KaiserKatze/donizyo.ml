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

    docker network create --driver bridge kknet
    docker network ls
    docker network inspect kknet

    # create new containers

    # setup dns service
    docker run -d \
        -p 127.0.0.1:53:53/udp \
        --name dns \
        bind \
        named -g -4 -u bind

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
        nginx \
        nginx -g 'daemon off;'
}

finalize() {
    docker rm -f dns
}
