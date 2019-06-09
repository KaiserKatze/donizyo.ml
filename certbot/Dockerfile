FROM        base AS certbot-install

# prevent installation of `tzdata` package enter interactive mode
# @see: https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive
ARG         DEBIAN_FRONTEND=noninteractive
RUN         apt-get -y install tzdata
# configure `tzdata`, using Beijing timezone
RUN         ln -sf /usr/share/zoneinfo/PRC /etc/localtime && \
            dpkg-reconfigure -f noninteractive tzdata

WORKDIR     $PATH_APP
ARG         GIT_CERTBOT=https://github.com/certbot/certbot
ARG         VERSION_CERTBOT=v0.35.0
RUN         git clone --verbose \
                --depth 1 \
                --single-branch \
                --branch $VERSION_CERTBOT \
                -- $GIT_CERTBOT certbot

WORKDIR     $PATH_APP/certbot
RUN         python setup.py --fullname
RUN         python setup.py build
RUN         python setup.py install

WORKDIR     $PATH_APP/certbot/certbot-dns-rfc2136
RUN         python setup.py --fullname
RUN         python setup.py build
RUN         python setup.py install

WORKDIR     $PATH_APP
RUN         rm -rf certbot

#=====================================================================
FROM        certbot-install AS certbot

ARG         WILDCARD_CERT_SERVER=https://acme-v02.api.letsencrypt.org/directory
RUN         export domain_name=$(cat /opt/domain) && \
            test -n "$domain_name" || \
            echo "File '/opt/domain' not found! DNS service is necessary!" && \
            exit 1

ARG         PATH_CERTBOT_INI=/opt/certbot/rfc2136.ini
RUN         dig @127.0.0.1 $domain_name || \
            echo "Fail to resolve '$domain_name' on localhost dns!" && \
            exit 1

# stop Nginx if it is running
# @see: https://certbot.eff.org/docs/using.html
RUN         which nginx && nginx -s quit || \
            echo "Nginx not found. Continue ..."

# register
# you either register with an email address:
#   `certbot register -m admin@example.com`
# or you could register without it:
#   `certbot register --register-unsafely-without-email`
ARG         EMAIL_ADDR=admin@localhost
RUN         certbot register \
                --agree-tos \
                --register-unsafely-without-email
# make sure you then backup your account key
# from /etc/letsencrypt/accounts
WORKDIR     /etc/letsencrypt
# clean unnecessary files
RUN         find ./accounts ! -name '*.json' -type f -print -delete
# backup account
RUN         tar -czvf accounts.tar.gz ./accounts

# obtain certificate
# `-n`: run non-interactively
RUN         certbot certonly -n \
                -a dns-rfc2136 \
                -d "$domain_name" \
                -d "*.$domain_name" \
                --dns-rfc2136-credentials $PATH_CERTBOT_INI \
                --dns-rfc2136-propagation-seconds 30 \
                --server $WILDCARD_CERT_SERVER

# Display information about certificates you have from Certbot
RUN         certbot certificates
