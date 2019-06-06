FROM        python AS bind

# DNS
EXPOSE      53/udp

ARG         GIT_BIND9=https://gitlab.isc.org/isc-projects/bind9.git
ARG         VERSION_BIND=v9_14_2
ARG         URL_BIND_KEYS=https://ftp.isc.org/isc/bind9/keys/9.11/bind.keys.v9_11

# bind
WORKDIR     $PATH_APP
RUN         git clone --verbose \
                --depth 1 \
                --single-branch \
                --branch $VERSION_BIND \
                -- $GIT_BIND9 bind9
RUN         python -m pip install ply
RUN         apt-get -y install libjson-c-dev
RUN         apt-get -y install libkrb5-dev
RUN         apt-get -y install libcap-dev
RUN         apt-get -y install libgeoip-dev

WORKDIR     $PATH_APP/bind9
RUN         test -d $PATH_PYTHON_PACKAGES && \
            ./configure \
                --prefix=/usr \
                --mandir=/usr/share/man \
                --libdir=/usr/lib/x86_64-linux-gnu \
                --infodir=/usr/share/info \
                --sysconfdir=/etc/bind \
                --localstatedir=/ \
                --enable-threads \
                --enable-largefile \
                --enable-shared \
                --enable-static \
                --with-libtool \
                --with-libjson \
                --with-geoip \
                --with-python=python \
                --with-python-install-dir=$PATH_PYTHON_PACKAGES \
                --with-openssl=$OPENSSL_PREFIX \
                --with-zlib=$ZLIB_PREFIX \
                --with-gssapi \
                --with-gnu-ld \
                --enable-full-report
# don't use parallel jobs (-j) when making BIND9
RUN         make
RUN         make install

# configuration
RUN         useradd -M -d /nonexistent -s /usr/sbin/nologin bind

WORKDIR     /etc/bind
# @see: https://www.isc.org/downloads/bind/bind-keys/
RUN         curl -sL -C - --retry 5 --retry-delay 60 $URL_BIND_KEYS -o bind.keys

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
            chown bind:bind /var/log/bind && \
            cd /var/log/bind && \
            touch query.log && \
            touch default.log && \
            chmod 644 *.log && \
            chown bind:bind *.log
RUN         chmod 755 /etc/init.d/bind9 && \
            cat /etc/init.d/bind9

# bind test
RUN         named -V || echo "Fail to compile BIND9!"
RUN         named-checkconf || echo "Invalid BIND9 configuration file!"
RUN         named-checkconf -z || echo "Invalid BIND9 configuration file!"
RUN         named-checkconf -xp || echo "Invalid BIND9 configuration file!"
# Use `named-checkzone` to check newly added authoritative answers
