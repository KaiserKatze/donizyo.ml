FROM        base AS openssl
LABEL       image=openssl:1.1.0k

ARG         GIT_OPENSSL=https://github.com/openssl/openssl
ARG         VERSION_OPENSSL=OpenSSL_1_1_0k
ENV         OPENSSL_PREFIX=/usr/local
ENV         OPENSSL_DIR=$OPENSSL_PREFIX/ssl
ENV         LD_LIBRARY_PATH=$OPENSSL_PREFIX/lib
ARG         URI_ENVVAR=/etc/environment

# openssl
RUN         git clone --verbose \
                --depth 1 \
                --single-branch \
                --branch "$VERSION_OPENSSL" \
                --no-tags \
                -- "$GIT_OPENSSL" openssl
WORKDIR     $PATH_APP/openssl
RUN         ./config \
                --prefix="$OPENSSL_PREFIX" \
                --openssldir="$OPENSSL_DIR" \
                no-comp

RUN         make -j4
RUN         make -j4 test
RUN         make install
RUN         echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> $URI_ENVVAR

WORKDIR     $PATH_APP
RUN         rm -rf openssl openssl.tar.gz
# openssl test
RUN         openssl version
