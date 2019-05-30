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

# install python2.7 on ubuntu:18.04(debian:buster)
ARG         APT_SOURCELIST=/etc/apt/sources.list
RUN         echo "deb http://ftp.de.debian.org/debian buster main" >> $APT_SOURCELIST
RUN         apt-get -y install python2.7
RUN         update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
# test if python2.7 is successfully installed
RUN         which python && python -V || \
            echo 'Python executable not found.' && \
            echo "Try to locate Python executable:" && \
            find / -name 'python*'

# zlib
ARG         URL_ZLIB_TARBALL=http://www.zlib.net/zlib-1.2.11.tar.gz

RUN         curl -sL "$URL_ZLIB_TARBALL" -o zlib.tar.gz && \
            tar -xf zlib.tar.gz --one-top-level=zlib --strip-components 1
RUN         cd "zlib" && \
            ./configure && \
            make && \
            make install
RUN         cd "zlib" && \
            make clean && \
            rm -f "$PATH_APP/zlib.tar.gz"
