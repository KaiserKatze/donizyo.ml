#!/usr/bin/docker
# vim: set syntax=dockerfile encoding=utf-8
FROM        alpine
LABEL       maintainer.name="KaiserKatze"
LABEL       maintainer.mail="donizyo@gmail.com"
LABEL       target="test"

EXPOSE      8080

WORKDIR     /tmp/httpecho

# Enable C compilation
RUN         apk add --no-cache \
                linux-headers \
                libc-dev \
                gcc

ADD         httpecho.c .

RUN         gcc httpecho.c -o httpecho

ENTRYPOINT  ["/tmp/httpecho/httpecho"]
