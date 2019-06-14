FROM        alpine AS base
LABEL       maintainer.name="KaiserKatze"
LABEL       maintainer.mail="donizyo@gmail.com"

ENV         PATH_APP=/root/App
ENV         PATH_TARGET=/tmp/target
ENV         URI_ENVVAR=/etc/environment

# install necessary tools
RUN         echo "Installing necessary packages:"
RUN         apk add curl tar git
# Install `gcc`, `ld`, `make`, etc.
RUN         apk add build-base
RUN         apk add linux-headers
# Install `gpg`
RUN         apk add gnupg

#==============================================================================
FROM        base AS util

ARG         URL_PCRE_TARBALL=https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz
ARG         URL_ZLIB_TARBALL=https://www.zlib.net/zlib-1.2.11.tar.gz
ARG         GIT_PERL=https://github.com/Perl/perl5
ARG         GIT_OPENSSL=https://github.com/openssl/openssl

ARG         VERSION_PERL=v5.30.0
ARG         VERSION_OPENSSL=OpenSSL_1_1_1c

ENV         PCRE_PREFIX=/usr/local
ENV         ZLIB_PREFIX=/usr/local
ENV         OPENSSL_PREFIX=/usr/local
ENV         PERL_PREFIX=/opt/perl5
ENV         OPENSSL_DIR=$OPENSSL_PREFIX/ssl
ARG         LD_LIBRARY_PATH=$OPENSSL_PREFIX/lib

# pcre
WORKDIR     $PATH_APP
RUN         curl -sL --retry 5 --retry-delay 60 $URL_PCRE_TARBALL -o pcre.tar.gz && \
            tar -xf pcre.tar.gz --one-top-level=pcre --strip-components 1 && \
            rm -f pcre.tar.gz
WORKDIR     $PATH_APP/pcre
RUN         ./configure --prefix=$PCRE_PREFIX
RUN         make
RUN         make install

# zlib
WORKDIR     $PATH_APP
RUN         curl -sL --retry 5 --retry-delay 60 $URL_ZLIB_TARBALL -o zlib.tar.gz && \
            tar -xf zlib.tar.gz --one-top-level=zlib --strip-components 1 && \
            rm -f zlib.tar.gz
WORKDIR     $PATH_APP/zlib
RUN         ./configure --prefix=$ZLIB_PREFIX
RUN         make
RUN         make install

# perl5
RUN         apk add perl

# openssl
WORKDIR     $PATH_APP
RUN         git clone -q --depth 1 --single-branch --branch $VERSION_OPENSSL -- $GIT_OPENSSL openssl
WORKDIR     $PATH_APP/openssl
RUN         ./config \
                --prefix=$OPENSSL_PREFIX \
                --openssldir=$OPENSSL_DIR \
                no-comp
RUN         make
RUN         make test
RUN         make install
RUN         echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> $URI_ENVVAR
# openssl test
RUN         which openssl && openssl version || echo "Fail to compile openssl!"
