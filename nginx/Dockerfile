FROM        openssl AS nginx
LABEL       image=nginx:1.16.0

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
ARG         PCRE_PREFIX=/usr/local
ARG         ZLIB_PREFIX=/usr/local

# pcre
RUN         curl -sL "$URL_PCRE_TARBALL" -o pcre.tar.gz && \
            tar -xf pcre.tar.gz --one-top-level=pcre --strip-components 1
WORKDIR     $PATH_APP/pcre
RUN         ./configure --prefix="$PCRE_PREFIX"
RUN         make
RUN         make install

WORKDIR     $PATH_APP
RUN         rm -rf pcre.tar.gz

# zlib
RUN         curl -sL "$URL_ZLIB_TARBALL" -o zlib.tar.gz && \
            tar -xf zlib.tar.gz --one-top-level=zlib --strip-components 1
WORKDIR     $PATH_APP/zlib
RUN         ./configure --prefix="$ZLIB_PREFIX"
RUN         make
RUN         make install

WORKDIR     $PATH_APP
RUN         rm -rf zlib.tar.gz


# nginx
RUN         curl -sL "$URL_NGINX_TARBALL" -o nginx.tar.gz && \
            tar -xf nginx.tar.gz --one-top-level=nginx --strip-components 1
WORKDIR     $PATH_APP/nginx

# nginx modules
RUN         git clone --verbose \
                --depth 1 \
                --single-branch \
                --branch "$VERSION_NGINX_RTMP_MODULE" \
                -- "$GIT_NGINX_RTMP_MODULE" nginx-rtmp-module

# @see: http://nginx.org/en/docs/configure.html
# compile --without-http_gzip_module, thus need not --with-zlib,
# because `gzip on` is not secure when using with `ssl`
RUN         ./configure --user=www-data --group=www-data \
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
                --without-http_gzip_module \
                --add-module="$PATH_APP/nginx/nginx-rtmp-module"
RUN         make
RUN         make install

WORKDIR     $PATH_APP
RUN         rm -rf pcre zlib nginx nginx.tar.gz

# configuration
WORKDIR     /tmp
ARG         GIT_SELF=https://github.com/donizyo/donizyo.ml.git
RUN         git clone --verbose \
                --depth 1 \
                --single-branch \
                --branch master \
                -- "$GIT_SELF" self
WORKDIR     /tmp/self/nginx

RUN         mkdir -p /etc/nginx && \
            chmod 2755 /etc/nginx && \
            chown root:root /etc/nginx && \
            cp -r .config/* /

WORKDIR     /tmp
RUN         rm -rf /tmp/self

# nginx test
RUN         nginx -V || echo "Fail to compile Nginx!"
RUN         nginx -T || echo "Invalid Nginx configuration file!"

WORKDIR     $PATH_APP
