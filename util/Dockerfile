FROM        base AS util

ARG         URL_PCRE_TARBALL=https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz
ARG         URL_ZLIB_TARBALL=https://www.zlib.net/zlib-1.2.11.tar.gz
ENV         PCRE_PREFIX=/usr/local
ENV         ZLIB_PREFIX=/usr/local
ARG         GIT_OPENSSL=https://github.com/openssl/openssl
ARG         VERSION_OPENSSL=OpenSSL_1_1_0k
ENV         OPENSSL_PREFIX=/usr/local
ENV         OPENSSL_DIR=$OPENSSL_PREFIX/ssl
ENV         LD_LIBRARY_PATH=$OPENSSL_PREFIX/lib
ARG         URI_ENVVAR=/etc/environment

# pcre
WORKDIR     $PATH_APP
RUN         curl -sL -C - --retry 5 --retry-delay 60 $URL_PCRE_TARBALL -o pcre.tar.gz && \
            tar -xf pcre.tar.gz --one-top-level=pcre --strip-components 1
WORKDIR     $PATH_APP/pcre
RUN         ./configure --prefix=$PCRE_PREFIX
RUN         make
RUN         make install
RUN         rm -f $PATH_APP/pcre.tar.gz

# zlib
WORKDIR     $PATH_APP
RUN         curl -sL -C - --retry 5 --retry-delay 60 $URL_ZLIB_TARBALL -o zlib.tar.gz && \
            tar -xf zlib.tar.gz --one-top-level=zlib --strip-components 1
WORKDIR     $PATH_APP/zlib
RUN         ./configure --prefix=$ZLIB_PREFIX
RUN         make
RUN         make install
RUN         rm -f $PATH_APP/zlib.tar.gz

# openssl
WORKDIR     $PATH_APP
RUN         git clone --verbose \
                --depth 1 \
                --single-branch \
                --branch $VERSION_OPENSSL \
                -- $GIT_OPENSSL openssl
WORKDIR     $PATH_APP/openssl
RUN         ./config \
                --prefix=$OPENSSL_PREFIX \
                --openssldir=$OPENSSL_DIR \
                no-comp
RUN         make
RUN         make test
RUN         make install
RUN         echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> $URI_ENVVAR
RUN         rm -f $PATH_APP/openssl.tar.gz
# openssl test
RUN         openssl version || echo "Fail to compile openssl!"
