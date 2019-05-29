FROM        python AS bind9
LABEL       image=bind:9.14.2

ARG         GIT_BIND9=https://gitlab.isc.org/isc-projects/bind9.git
ARG         VERSION_BIND=v9_14_2

# bind
RUN         git clone --verbose \
                --depth 1 \
                --single-branch \
                --branch "$VERSION_BIND" \
                --no-tags \
                -- "$GIT_BIND9" bind9
RUN         python -m pip install ply && \
            apt-get -y install libjson-c-dev libkrb5-dev
RUN         cd "bind9" && \
            test -d "$PATH_PYTHON_PACKAGES" && \
            ./configure \
                --prefix=/usr \
                --mandir=/usr/share/man \
                --libdir=/usr/lib/x86_64-linux-gnu \
                --infodir=/usr/share/info \
                --sysconfdir=/etc/bind \
                --localstatedir=/ \
                --enable-largefile \
                --with-libtool \
                --with-libjson \
                --with-zlib="$ZLIB_PREFIX" \
                --with-python=python \
                --with-python-install-dir="$PATH_PYTHON_PACKAGES" \
                --with-openssl="$OPENSSL_PREFIX" \
                --with-gssapi \
                --with-gnu-ld \
                --enable-full-report && \
            make && \
            make install
RUN         cd "bind9" && \
            make clean
# bind test
RUN         named -V
RUN         named -g
