#!/usr/bin/docker
# vim: set syntax=dockerfile encoding=utf-8
FROM        alpine AS alpine-base
LABEL       maintainer.name="KaiserKatze"
LABEL       maintainer.mail="donizyo@gmail.com"
LABEL       target="test"

# Enable C compilation
RUN         apk add --no-cache \
                linux-headers \
                libc-dev \
                gcc

#==================================================
FROM        alpine-base

EXPOSE      8080

WORKDIR     /tmp/httpecho
ADD         httpecho.c .
RUN         gcc httpecho.c -o httpecho

ENTRYPOINT  ["/tmp/httpecho/httpecho"]
