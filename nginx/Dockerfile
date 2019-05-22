# Compile and Install Nginx

FROM        openssl:1.1.1b AS base
LABEL       maintainer.name="KaiserKatze" \
            maintainer.mail="donizyo@gmail.com"
WORKDIR     /tmp/workdir

#=======================================================
# HTTP
EXPOSE      80/tcp
# HTTPS
EXPOSE      443/tcp
# RTMP
EXPOSE      1935/tcp

ARG         PATH_APP=/root/App
ARG         URL_PCRE_TARBALL=https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz
ARG         URL_ZLIB_TARBALL=http://www.zlib.net/zlib-1.2.11.tar.gz
ARG         URL_NGINX_TARBALL=http://nginx.org/download/nginx-1.16.0.tar.gz
ARG         PCRE_PREFIX=/usr/local/pcre
ARG         ZLIB_PREFIX=/usr/local/zlib

# pcre
RUN         cd "$PATH_APP" && \
            curl -sL "$URL_PCRE_TARBALL" -o pcre.tar.gz && \
            tar -xf pcre.tar.gz --one-top-level=pcre --strip-components 1 && \
            cd "$PATH_APP/pcre" && \
            ./configure --prefix="$PCRE_PREFIX" && \
            make && \
            make install
# zlib
RUN         cd "$PATH_APP" && \
            curl -sL "$URL_ZLIB_TARBALL" -o zlib.tar.gz && \
            tar -xf zlib.tar.gz --one-top-level=zlib --strip-components 1 && \
            cd "$PATH_APP/zlib" && \
            ./configure --prefix="$ZLIB_PREFIX" && \
            make && \
            make install
# nginx
RUN         cd "$PATH_APP" && \
            curl -sL "$URL_NGINX_TARBALL" -o nginx.tar.gz && \
            tar -xf nginx.tar.gz --one-top-level=nginx --strip-components 1 && \
            cd "$PATH_APP/nginx" && \
            git clone https://github.com/arut/nginx-rtmp-module && \
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
            make install

# configure nginx
