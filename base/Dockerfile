FROM        ubuntu:18.04 AS base
LABEL       maintainer.name="KaiserKatze"
LABEL       maintainer.mail="donizyo@gmail.com"

ENV         PATH_APP=/root/App
WORKDIR     $PATH_APP

# list installed packages
RUN         echo "Installed packages:" && \
            dpkg -l

# install necessary tools
RUN         echo "Installing necessary packages:" && \
            apt-get update && \
            apt-get -y install curl tar git && \
            apt-get -y install build-essential
# Install `ip`
RUN         apt-get -y install iproute2
# Install editor
RUN         apt-get -y install vim

# install python2.7 on ubuntu:18.04(debian:buster)
ARG         APT_SOURCELIST=/etc/apt/sources.list
RUN         echo "deb http://ftp.de.debian.org/debian buster main" >> $APT_SOURCELIST
RUN         apt-get -y install python2.7
RUN         update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1

WORKDIR     /tmp
ARG         GIT_SELF=https://github.com/donizyo/donizyo.ml.git
RUN         git clone --verbose \
                --depth 1 \
                --single-branch \
                --branch master \
                -- $GIT_SELF self
