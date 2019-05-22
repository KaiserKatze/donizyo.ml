# Compile and Install OpenSSL

FROM        ubuntu:18.04 AS base
LABEL       maintainer.name="KaiserKatze" \
            maintainer.mail="donizyo@gmail.com"
WORKDIR     /tmp/workdir

ENV         PATH_APP=/root/App
ARG         URL_OPENSSL_TARBALL=https://www.openssl.org/source/openssl-1.1.1b.tar.gz
ENV         OPENSSL_PREFIX=/usr/local/openssl
ENV         OPENSSL_DIR=$OPENSSL_PREFIX/conf

#
RUN         echo "Installed APT packages:" && \
            dpkg -l
RUN         echo "Installing necessary APT packages:" && \
            apt-get -qq update > /dev/null && \
            apt-get -qq -y install build-essential curl tar git > /dev/null

RUN         mkdir -p "$PATH_APP"
# openssl
RUN         cd "$PATH_APP" && \
            curl -sL "$URL_OPENSSL_TARBALL" -o openssl.tar.gz && \
            tar -xf openssl.tar.gz --one-top-level=openssl --strip-components 1 && \
            cd "$PATH_APP/openssl" && \
            ./config --prefix="$OPENSSL_PREFIX" --openssldir="$OPENSSL_DIR" > /dev/null && \
            make > /dev/null && \
            make install > /dev/null \
            make clean > /dev/null
