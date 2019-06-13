#!/bin/bash

set -Ee
onerror() {
    echo "Fail to execute: $0 $@ ($?)"
    exit 1
}
# exit 1 on error
trap onerror ERR

install_docker() {
    # @see: https://docs.docker.com/install/linux/docker-ce/ubuntu/
    apt-get update
    apt-get -y install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"
    apt-get update
    apt-get -y install docker-ce docker-ce-cli containerd.io
}

# setup firewall before docker does so

disable_docker_firewall() {
    cat > /etc/default/docker <<- EOF
    # Docker Upstart and SysVinit configuration file

    #
    # THIS FILE DOES NOT APPLY TO SYSTEMD
    #
    #   Please see the documentation for "systemd drop-ins":
    #   https://docs.docker.com/engine/admin/systemd/
    #

    # Customize location of Docker binary (especially for development testing).
    #DOCKERD="/usr/local/bin/dockerd"

    # Use DOCKER_OPTS to modify the daemon startup options.
    #DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4"
    DOCKER_OPTS="--iptables=false"

    # If you need Docker to use an HTTP proxy, it can also be specified here.
    #export http_proxy="http://127.0.0.1:3128/"

    # This is also a handy place to tweak where Docker's temporary files go.
    #export DOCKER_TMPDIR="/mnt/bigdrive/docker-tmp"
    EOF
}

start() {
    # create user-defined bridge network
    # @see: https://docs.docker.com/network/network-tutorial-standalone/

    docker network create --driver bridge kknet

    # firewall
    disable_docker_firewall
    service docker restart
    ./iptables.sh

    # delete all containers
    docker rm -f $(docker ps -a -q)

    # create new containers

    # setup dns service
    docker run -dit \
        -p 127.0.0.1:53:53/udp \
        --name dns \
        --network kknet \
        bind bash
    docker exec -d dns /etc/init.d/bind9 start

    dns4_service_status=$(ip -4 addr show | awk '/inet/' | grep -Po "inet \K\d+\.\d+\.\d+\.\d+" | xargs nmap -T4 -Pn -n -p53 | grep -Po "53/\w+\s+open")
    dns6_service_status=$(ip -6 addr show | awk '/inet6/' | grep -Po "inet6 \K[^/]+" | xargs nmap -T4 -Pn -n -6 -p53 | grep -Po "53/\w+\s+open")
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
    docker run -dit \
        -p 127.0.0.1:80:80/tcp \
        -p 127.0.0.1:443:443/tcp \
        -p 127.0.0.1:1935:1935/tcp \
        -v "/etc/letsencrypt:/etc/letsencrypt" \
        -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
        --name web \
        --network kknet \
        nginx bash
    docker exec -d web nginx
}

finalize() {
    containers="dns web"
    for container in $containers; do
        docker stop $container
        docker rm $container
    done
}
