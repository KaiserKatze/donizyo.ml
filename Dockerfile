# Compile and Install Nginx, Python, Bind9
# maintainer.name="KaiserKatze"
# maintainer.mail="donizyo@gmail.com"

#===========================================================================
FROM        ubuntu:18.04 AS base
WORKDIR     /tmp/workdir

ENV         PATH_APP=/root/App

RUN         echo "Installed APT packages:" && \
            dpkg -l
RUN         echo "Installing necessary APT packages:" && \
            apt-get -qq update && \
            apt-get -qq -y install build-essential curl tar git
RUN         mkdir -p "$PATH_APP"
#===========================================================================
FROM        base AS openssl

ARG         URL_OPENSSL_TARBALL=https://www.openssl.org/source/openssl-1.1.1b.tar.gz
ARG         OPENSSL_PREFIX=/usr/local/openssl
ARG         OPENSSL_DIR=$OPENSSL_PREFIX/conf

RUN         cd "$PATH_APP" && \
            curl -sL "$URL_OPENSSL_TARBALL" -o openssl.tar.gz && \
            tar -xf openssl.tar.gz --one-top-level=openssl --strip-components 1
RUN         cd "$PATH_APP/openssl" && \
            ./config --prefix="$OPENSSL_PREFIX" --openssldir="$OPENSSL_DIR" && \
            make && \
            make install && \
            make clean
#===========================================================================
FROM        openssl AS nginx

# HTTP
EXPOSE      80/tcp
# HTTPS
EXPOSE      443/tcp
# RTMP
EXPOSE      1935/tcp

ARG         URL_PCRE_TARBALL=https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz
ARG         URL_ZLIB_TARBALL=http://www.zlib.net/zlib-1.2.11.tar.gz
ARG         URL_NGINX_TARBALL=http://nginx.org/download/nginx-1.16.0.tar.gz
ARG         GIT_NGINX_RTMP_MODULE=https://github.com/arut/nginx-rtmp-module
ARG         VERSION_NGINX_RTMP_MODULE=v1.2.1
ARG         PCRE_PREFIX=/usr/local/pcre
ARG         ZLIB_PREFIX=/usr/local/zlib

# pcre
RUN         cd "$PATH_APP" && \
            curl -sL "$URL_PCRE_TARBALL" -o pcre.tar.gz && \
            tar -xf pcre.tar.gz --one-top-level=pcre --strip-components 1
RUN         cd "$PATH_APP/pcre" && \
            ./configure --prefix="$PCRE_PREFIX" && \
            make && \
            make install && \
            make clean
# zlib
RUN         cd "$PATH_APP" && \
            curl -sL "$URL_ZLIB_TARBALL" -o zlib.tar.gz && \
            tar -xf zlib.tar.gz --one-top-level=zlib --strip-components 1
RUN         cd "$PATH_APP/zlib" && \
            ./configure --prefix="$ZLIB_PREFIX" && \
            make && \
            make install && \
            make clean
# nginx
RUN         cd "$PATH_APP" && \
            curl -sL "$URL_NGINX_TARBALL" -o nginx.tar.gz && \
            tar -xf nginx.tar.gz --one-top-level=nginx --strip-components 1 && \
            cd "$PATH_APP/nginx" && \
            git clone --verbose \
                --depth 1 \
                --single-branch \
                --branch "$VERSION_NGINX_RTMP_MODULE" \
                --no-tags \
                -- "$GIT_NGINX_RTMP_MODULE" nginx-rtmp-module
RUN         cd "$PATH_APP/nginx" && \
            ./configure --user=www-data --group=www-data \
                --prefix=/usr/local/nginx \
                --with-threads \
                --with-file-aio \
                --with-http_ssl_module \
                --with-http_v2_module \
                --with-http_realip_module \
                --with-http_stub_status_module \
                --with-openssl="$PATH_APP/openssl" \
                --with-pcre="$PATH_APP/pcre" \
                --with-zlib="$PATH_APP/zlib" \
                --add-module="$PATH_APP/nginx/nginx-rtmp-module" && \
            make && \
            make install && \
            make clean
