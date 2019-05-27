# Compile and Install Nginx, Python, Bind9
# maintainer.name="KaiserKatze"
# maintainer.mail="donizyo@gmail.com"

#===========================================================================
FROM        ubuntu:18.04 AS base

ENV         PATH_APP=/root/App
WORKDIR     $PATH_APP
ARG         APT_SOURCELIST=/etc/apt/sources.list

RUN         echo "Installed APT packages:" && \
            dpkg -l

RUN         echo "Installing necessary APT packages:" && \
            apt-get update && \
            apt-get -y install curl tar git gnupg cmake
# `curl`: used to download files
# `tar`: used to unpack/decompress archives
# `git`: do git stuffs
# `gnupg`: necessary for `apt-key`

# @see: [LLVM Debian/Ubuntu packages](https://apt.llvm.org/)
RUN         echo "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic main" >> $APT_SOURCELIST && \
            echo "deb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic main" >> $APT_SOURCELIST && \
            curl -sL https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
            apt-get -y install clang-7 lldb-7 lld-7

# install python2.7 on ubuntu:18.04(debian:buster)
RUN         echo "deb http://ftp.de.debian.org/debian buster main" >> $APT_SOURCELIST
RUN         apt-get -y install python2.7
RUN         update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1

RUN         which python && python -V || \
            echo 'Python executable not found.' && \
            echo "Try to locate Python executable:" && \
            find / -name 'python*'
#===========================================================================
FROM        base AS openssl
LABEL       image=openssl:1.1.1b

ARG         URL_OPENSSL_TARBALL=https://www.openssl.org/source/openssl-1.1.1b.tar.gz
ENV         OPENSSL_PREFIX=/usr/local
ENV         OPENSSL_DIR=$OPENSSL_PREFIX/ssl
ENV         LD_LIBRARY_PATH=$OPENSSL_PREFIX/lib
ARG         URI_ENVVAR=/etc/environment

# openssl
RUN         curl -sL "$URL_OPENSSL_TARBALL" -o openssl.tar.gz && \
            tar -xf openssl.tar.gz --one-top-level=openssl --strip-components 1
WORKDIR     $PATH_APP/openssl
RUN         ./config \
                --prefix="$OPENSSL_PREFIX" \
                --openssldir="$OPENSSL_DIR" \
                --api=1.1.0 \
                no-comp
RUN         make
RUN         make test
RUN         make install
RUN         echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> $URI_ENVVAR

WORKDIR     $PATH_APP
RUN         rm -rf openssl openssl.tar.gz
# openssl test
RUN         openssl version
#===========================================================================
#FROM        openssl AS nginx
#LABEL       image=nginx:1.16.0
#
## HTTP
#EXPOSE      80/tcp
## HTTPS
#EXPOSE      443/tcp
## RTMP
#EXPOSE      1935/tcp
#
#ARG         URL_ZLIB_TARBALL=http://www.zlib.net/zlib-1.2.11.tar.gz
#ARG         URL_PCRE_TARBALL=https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz
#ARG         URL_NGINX_TARBALL=http://nginx.org/download/nginx-1.16.0.tar.gz
#ARG         GIT_NGINX_RTMP_MODULE=https://github.com/arut/nginx-rtmp-module
#ARG         VERSION_NGINX_RTMP_MODULE=v1.2.1
#ENV         ZLIB_PREFIX=/usr/local
#ARG         PCRE_PREFIX=/usr/local
#
## zlib
#RUN         curl -sL "$URL_ZLIB_TARBALL" -o zlib.tar.gz && \
#            tar -xf zlib.tar.gz --one-top-level=zlib --strip-components 1
#RUN         cd "zlib" && \
#            ./configure --prefix="$ZLIB_PREFIX" && \
#            make && \
#            make install
#RUN         cd "zlib" && \
#            make clean && \
#            rm -f "$PATH_APP/zlib.tar.gz"
## pcre
#RUN         curl -sL "$URL_PCRE_TARBALL" -o pcre.tar.gz && \
#            tar -xf pcre.tar.gz --one-top-level=pcre --strip-components 1
#RUN         cd "pcre" && \
#            ./configure --prefix="$PCRE_PREFIX" && \
#            make && \
#            make install
#RUN         cd "pcre" && \
#            make clean && \
#            rm -f "$PATH_APP/pcre.tar.gz"
## nginx
#RUN         curl -sL "$URL_NGINX_TARBALL" -o nginx.tar.gz && \
#            tar -xf nginx.tar.gz --one-top-level=nginx --strip-components 1 && \
#            cd "nginx" && \
#            git clone --verbose \
#                --depth 1 \
#                --single-branch \
#                --branch "$VERSION_NGINX_RTMP_MODULE" \
#                --no-tags \
#                -- "$GIT_NGINX_RTMP_MODULE" nginx-rtmp-module
#RUN         cd "nginx" && \
#            ./configure --user=www-data --group=www-data \
#                --prefix=/usr/local/nginx \
#                --with-threads \
#                --with-file-aio \
#                --with-http_ssl_module \
#                --with-http_v2_module \
#                --with-http_realip_module \
#                --with-http_stub_status_module \
#                --with-openssl="$PATH_APP/openssl" \
#                --with-pcre="$PATH_APP/pcre" \
#                --with-zlib="$PATH_APP/zlib" \
#                --add-module="$PATH_APP/nginx/nginx-rtmp-module" && \
#            make && \
#            make install
#RUN         cd "nginx" && \
#            make clean && \
#            rm -f "$PATH_APP/nginx.tar.gz"
#===========================================================================
FROM        openssl AS sqlite
LABEL       image=sqlite:3.28.0

ARG         URL_SQLITE_TARBALL=https://www.sqlite.org/2019/sqlite-autoconf-3280000.tar.gz
ARG         SQLITE_PREFIX=/usr/local

# sqlite
RUN         curl -sL "$URL_SQLITE_TARBALL" -o sqlite.tar.gz && \
            tar -xf sqlite.tar.gz --one-top-level=sqlite --strip-components 1
WORKDIR     $PATH_APP/sqlite
RUN         ./configure --prefix="$SQLITE_PREFIX"
RUN         make
RUN         make install

# @see: [How SQLite Is Tested](https://www.sqlite.org/testing.html)

WORKDIR     $PATH_APP
RUN         rm -rf sqlite sqlite.tar.gz
#===========================================================================
FROM        sqlite AS python
LABEL       image=python:3.7.3

# @see: [libuuid download | SourceForge.net](https://sourceforge.net/projects/libuuid/)
ARG         URL_UUID_TARBALL=https://nchc.dl.sourceforge.net/project/libuuid/libuuid-1.0.3.tar.gz
ARG         URL_PYTHON_TARBALL=https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz
ENV         PATH_PYTHON_PACKAGES="/usr/local/lib/python3.7/site-packages"
ARG         LD_RUN_PATH=$LD_LIBRARY_PATH
# --enable-optimizations
ARG         OPTIONAL_PYTHON_CONFIG=

# uuid
#RUN         curl -sL "$URL_UUID_TARBALL" -o libuuid.tar.gz && \
#            tar -xf libuuid.tar.gz --one-top-level=libuuid --strip-components 1
#RUN         cd "libuuid" && \
#            ./configure && \
#            make && \
#            make install
#RUN         cd "libuuid" && \
#            make clean && \
#            rm -f "$PATH_APP/libuuid.tar.gz"

# python
RUN         curl -sL "$URL_PYTHON_TARBALL" -o python.tar.xz && \
            tar -xf python.tar.xz --one-top-level=python --strip-components 1

WORKDIR     $PATH_APP/python
RUN         ./configure \
                --enable-ipv6 \
                --enable-profiling \
                --enable-shared \
                --with-lto \
                --with-openssl="$OPENSSL_PREFIX" \
                "$OPTIONAL_PYTHON_CONFIG"
RUN         cat config.log
RUN         make
RUN         make install

WORKDIR     $PATH_APP
RUN         rm -rf python python.tar.xz

RUN         cat "/usr/local/lib/" > "/etc/ld.so.conf.d/python3.conf" && ldconfig && \
            update-alternatives --install /usr/local/bin/python python /usr/local/bin/python3 10
# manually check update-alternatives
RUN         update-alternatives --display python

# python test
RUN         python -V
RUN         python -c "import ssl"
RUN         python -c "import sqlite3"

# upgrade pip - package manager
RUN         python -m pip --upgrade pip
#===========================================================================
#FROM        python AS bind9
#LABEL       image=bind:9.14.2
#
#ARG         GIT_BIND9=https://gitlab.isc.org/isc-projects/bind9.git
#ARG         VERSION_BIND=v9_14_2
#
## bind
#RUN         git clone --verbose \
#                --depth 1 \
#                --single-branch \
#                --branch "$VERSION_BIND" \
#                --no-tags \
#                -- "$GIT_BIND9" bind9
#RUN         python -m pip install ply && \
#            apt-get -y install libjson-c-dev libkrb5-dev
#RUN         cd "bind9" && \
#            test -d "$PATH_PYTHON_PACKAGES" && \
#            ./configure \
#                --prefix=/usr \
#                --mandir=/usr/share/man \
#                --libdir=/usr/lib/x86_64-linux-gnu \
#                --infodir=/usr/share/info \
#                --sysconfdir=/etc/bind \
#                --localstatedir=/ \
#                --enable-largefile \
#                --with-libtool \
#                --with-libjson \
#                --with-zlib="$ZLIB_PREFIX" \
#                --with-python=python \
#                --with-python-install-dir="$PATH_PYTHON_PACKAGES" \
#                --with-openssl="$OPENSSL_PREFIX" \
#                --with-gssapi \
#                --with-gnu-ld \
#                --enable-full-report && \
#            make && \
#            make install
#RUN         cd "bind9" && \
#            make clean
## bind test
#RUN         named -V
#RUN         named -g
