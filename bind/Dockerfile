FROM        python AS bind
LABEL       image=bind:9.14.2

# DNS
EXPOSE      53/udp

ARG         GIT_BIND9=https://gitlab.isc.org/isc-projects/bind9.git
ARG         VERSION_BIND=v9_14_2

# bind
RUN         git clone --verbose \
                --depth 1 \
                --single-branch \
                --branch "$VERSION_BIND" \
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
RUN         make
RUN         make install

WORKDIR     $PATH_APP
RUN         rm -rf bind9

# configuration
RUN         useradd -M -d /nonexistent -s /usr/sbin/nologin bind

WORKDIR     /etc/bind
# @see: https://www.isc.org/downloads/bind/bind-keys/
RUN         curl -sL https://ftp.isc.org/isc/bind9/keys/9.11/bind.keys.v9_11 -o bind.keys

WORKDIR     /tmp
ARG         GIT_SELF=https://github.com/donizyo/donizyo.ml.git
RUN         git clone --verbose \
                --depth 1 \
                --single-branch \
                --branch master \
                -- "$GIT_SELF" self
WORKDIR     /tmp/self/bind

RUN         cp -r .config/* /
RUN         chmod 644 /etc/logrotate.d/bind && \
            chown root:root /etc/logrotate.d/bind
RUN         chmod 2755 /etc/bind && \
            chown -R bind:bind /etc/bind && \
            chmod 644 /etc/bind/* && \
            mkdir -p /etc/bind/zones && \
            chmod 2755 /etc/bind/zones
RUN         mkdir -p /var/cache/bind && \
            chmod 2755 /var/cache/bind && \
            chown bind:bind /var/cache/bind
RUN         mkdir -p /var/log/bind && \
            chmod 2755 /var/log/bind && \
            chown bind:bind /var/log/bind
RUN         chmod 755 /etc/init.d/bind9

WORKDIR     /tmp
RUN         rm -rf /tmp/self

# bind test
RUN         named -V || echo "Fail to compile BIND9!"
RUN         named-checkconf || echo "Invalid BIND9 configuration file!"
RUN         named-checkconf -z || echo "Invalid BIND9 configuration file!"
RUN         named-checkconf -xp || echo "Invalid BIND9 configuration file!"
# Use `named-checkzone` to check newly added authoritative answers
