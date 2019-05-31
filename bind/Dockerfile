FROM        python AS bind
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
            apt-get -y install libjson-c-dev libkrb5-dev libcap-dev

WORKDIR     $PATH_APP/bind9
RUN         test -d "$PATH_PYTHON_PACKAGES" && \
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
                --with-python=python \
                --with-python-install-dir="$PATH_PYTHON_PACKAGES" \
                --with-openssl="$OPENSSL_PREFIX" \
                --with-gssapi \
                --with-gnu-ld \
                --enable-full-report
RUN         make -j4
RUN         make install

WORKDIR     $PATH_APP
RUN         rm -rf bind9

# bind test
RUN         named -V
WORKDIR     /etc/bind
RUN         rndc-confgen -a
RUN         touch named.conf
RUN         named -g
RUN         ps -ef | grep named
RUN         rndc status
RUN         dig @127.0.0.1 . NS
