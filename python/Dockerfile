# Compile and Install Python
# @see: https://github.com/docker-library/python/blob/34c9df35e9a69e9f0edde88e861b543edb8bc07a/3.7/stretch/Dockerfile

FROM        ubuntu:18.04 AS base
MAINTAINER  KaiserKatze
WORKDIR     /tmp/workdir

ARG         PATH_APP=/root/App
ARG         URL_OPENSSL_TARBALL=https://www.openssl.org/source/openssl-1.1.1b.tar.gz
ARG         URL_SQLITE_TARBALL=https://www.sqlite.org/2019/sqlite-autoconf-3280000.tar.gz
ARG         URL_PYTHON_TARBALL=https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz
ARG         OPENSSL_PREFIX=/usr/local/openssl
ARG         OPENSSL_DIR=$OPENSSL_PREFIX/conf
ARG         SQLITE_PREFIX=/usr/local/sqlite

#
RUN         echo "Installed APT packages:" && \
            dpkg -l
RUN         apt-get -qq update > /dev/null && \
            apt-get -qq -y install build-essential curl tar git > /dev/null

RUN         rm -rf "$PATH_APP" && \
            mkdir -p "$PATH_APP"
# openssl
RUN         cd "$PATH_APP" && \
            curl -sL "$URL_OPENSSL_TARBALL" -o openssl.tar.gz && \
            tar -xf openssl.tar.gz --one-top-level=openssl --strip-components 1 && \
            cd "$PATH_APP/openssl" && \
            ./config --prefix="$OPENSSL_PREFIX" --openssldir="$OPENSSL_DIR" && \
            make && \
            make install
# sqlite
RUN         cd "$PATH_APP" && \
            curl -sL "$URL_SQLITE_TARBALL" -o sqlite.tar.gz && \
            tar -xf sqlite.tar.gz --one-top-level=sqlite --strip-components 1 && \
            cd "$PATH_APP/sqlite" && \
            ./config --prefix="$SQLITE_PREFIX" && \
            make && \
            make install
# python
RUN         cd "$PATH_APP" && \
            curl -sL "$URL_PYTHON_TARBALL" -o python.tar.xz && \
            tar -xf python.tar.xz --one-top-level=python --strip-components 1 &&  \
            cd "$PATH_APP/python" && \
            ./configure --enable-optimizations \
                --enable-ipv6 \
                --enable-profiling \
                --enable-shared \
                --with-lto \
                --with-ssl-default-suites=python \
                --with-openssl="$OPENSSL_PREFIX" && \
            cat "/usr/local/lib/" > "/etc/ld.so.conf.d/python3.conf" && ldconfig && \
            update-alternatives --install /usr/local/bin/python python /usr/local/bin/python3 1 && \
            python -m pip --upgrade pip

