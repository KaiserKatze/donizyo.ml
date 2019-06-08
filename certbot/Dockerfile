FROM        python AS certbot

# check dependencies
ARG         which named && named -v || exit 1

# prevent installation of `tzdata` package enter interactive mode
# @see: https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive
ARG         DEBIAN_FRONTEND=noninteractive
RUN         apt-get -y install tzdata
# configure `tzdata`, using Beijing timezone
RUN         ln -sf /usr/share/zoneinfo/PRC /etc/localtime && \
            dpkg-reconfigure -f noninteractive tzdata
# Install Let's Encrypt - Certbot
RUN         apt-get update && \
            apt-get -y install software-properties-common && \
            add-apt-repository -y universe && \
            add-apt-repository -y ppa:certbot/certbot && \
            apt-get update && \
            apt-get -y install python3-certbot-dns-rfc2136

ARG         WILDCARD_CERT_SERVER=https://acme-v02.api.letsencrypt.org/directory
RUN         export domain_name=$(cat /opt/domain) && \
            test -n "$domain_name" || \
            echo "File '/opt/domain' not found! DNS service is necessary!" && \
            exit 1
ARG         PATH_CERTBOT_INI=/opt/certbot/rfc2136.ini
RUN         dig @127.0.0.1 $domain_name || \
            echo "Fail to resolve '$domain_name' on localhost dns!" && \
            exit 1
RUN         which nginx && nginx -s quit || \
            echo "Nginx not found. Continue ..."
RUN         certbot certonly -n \
                --standalone \
                -d "$domain_name" \
                -d "*.$domain_name" \
                --dns-rfc2136 \
                --dns-rfc2136-credentials $PATH_CERTBOT_INI \
                --dns-rfc2136-propagation-seconds 30 \
                --server $WILDCARD_CERT_SERVER

# Display information about certificates you have from Certbot
RUN         certbot certificates
