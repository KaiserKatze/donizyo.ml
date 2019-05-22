# Compile and Install BIND9
#  - docker build -t bind:9.14.2 bind

FROM        python:3.7.3 AS base
LABEL       maintainer.name="KaiserKatze" \
            maintainer.mail="donizyo@gmail.com"
WORKDIR     /tmp/workdir

ARG         PATH_APP=/root/App
ARG         URL_BIND9_GIT_REPO=https://gitlab.isc.org/isc-projects/bind9.git
ARG         VERSION_BIND=v9_14_2

ARG         PATH_PYTHON_PACKAGES="/usr/local/lib/python3.7/site-packages"

# bind
RUN         git clone --verbose \
                --depth 1 \
                --single-branch \
                --branch "$VERSION_BIND" \
                --no-tags \
                -- "$URL_BIND9_GIT_REPO" bind9 && \
            cd bind9 && \
            python -m pip install ply && \
            test -d "$PATH_PYTHON_PACKAGES" && \
            ./configure --prefix=/usr \
                --mandir=/usr/share/man \
                --libdir=/usr/lib/x86_64-linux-gnu \
                --infodir=/usr/share/info \
                --sysconfdir=/etc/bind \
                --localstatedir=/ \
                --enable-threads \
                --enable-largefile \
                --enable-kqueue \
                --enable-epoll \
                --enable-shared \
                --enable-static \
                --with-libtool \
                --with-libxml2 \
                --with-gost=no \
                --with-python=python \
                --with-python-install-dir="$PATH_PYTHON_PACKAGES" \
                --with-openssl="$OPENSSL_PREFIX" \
                --with-gssapi=/usr \
                --with-gnu-ld \
                --with-atf=no \
                --enable-ipv6 \
                --enable-rrl \
                --enable-filter-aaaa \
                --with-randomdev=/dev/urandom \
                --enable-full-report && \
            make && \
            make install && \
            make clean > /dev/null
