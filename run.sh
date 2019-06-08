#!/bin/bash

set -Ee
onerror() {
    echo "Fail to execute: $0 $@ ($?)"
    exit 1
}
# exit 1 on error
trap onerror ERR

# setup firewall before docker does so

# delete all containers
docker rm $(docker ps -a -q)

hostname=matrix

# create new containers

# setup dns service
docker run -d \
    -p 127.0.0.1:53:53/udp \
    --name dns \
    --hostname $hostname \
    bind \
    /etc/init.d/bind9 start

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
    --name web \
    --hostname $hostname \
    nginx \
    nginx
