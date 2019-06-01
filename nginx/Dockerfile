FROM        openssl AS nginx
LABEL       image=nginx:1.16.0

# HTTP
EXPOSE      80/tcp
# HTTPS
EXPOSE      443/tcp
# RTMP
EXPOSE      1935/tcp

ARG         URL_PCRE_TARBALL=https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz
ARG         URL_NGINX_TARBALL=http://nginx.org/download/nginx-1.16.0.tar.gz
ARG         GIT_NGINX_RTMP_MODULE=https://github.com/arut/nginx-rtmp-module
ARG         VERSION_NGINX_RTMP_MODULE=v1.2.1
ARG         PCRE_PREFIX=/usr/local

# pcre
RUN         curl -sL "$URL_PCRE_TARBALL" -o pcre.tar.gz && \
            tar -xf pcre.tar.gz --one-top-level=pcre --strip-components 1
RUN         cd "pcre" && \
            ./configure --prefix="$PCRE_PREFIX" && \
            make && \
            make install
RUN         cd "pcre" && \
            make clean && \
            rm -f "$PATH_APP/pcre.tar.gz"
# nginx
RUN         curl -sL "$URL_NGINX_TARBALL" -o nginx.tar.gz && \
            tar -xf nginx.tar.gz --one-top-level=nginx --strip-components 1 && \
            cd "nginx" && \
            git clone --verbose \
                --depth 1 \
                --single-branch \
                --branch "$VERSION_NGINX_RTMP_MODULE" \
                -- "$GIT_NGINX_RTMP_MODULE" nginx-rtmp-module
RUN         cd "nginx" && \
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
RUN         cd "nginx" && \
            make clean && \
            rm -f "$PATH_APP/nginx.tar.gz"
