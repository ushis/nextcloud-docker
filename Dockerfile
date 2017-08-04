FROM alpine:3.5

# Hack to work around a bug (?) in iconv
#
# See https://github.com/docker-library/php/issues/240#issuecomment-305038173
RUN apk add --no-cache \
  --repository http://dl-3.alpinelinux.org/alpine/edge/testing \
  gnu-libiconv

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

RUN apk add --no-cache \
  apache2 \
  ca-certificates \
  curl \
  php5-apache2 \
  php5-apcu \
  php5-bz2 \
  php5-ctype \
  php5-curl \
  php5-dom \
  php5-gd \
  php5-iconv \
  php5-intl \
  php5-json \
  php5-ldap \
  php5-mcrypt \
  php5-opcache \
  php5-openssl \
  php5-pdo \
  php5-pdo_pgsql \
  php5-pgsql \
  php5-posix \
  php5-xml \
  php5-xmlreader \
  php5-zip \
  php5-zlib

RUN curl -L https://download.nextcloud.com/server/releases/nextcloud-12.0.0.tar.bz2 | \
    tar -C /srv -xjf -

COPY config/* /srv/nextcloud/config/

RUN mkdir -p /srv/nextcloud/data && \
  mkdir -p /srv/nextcloud/custom_apps && \
  find /srv/nextcloud -type f -print0 | xargs -0 chmod 0640 && \
  find /srv/nextcloud -type d -print0 | xargs -0 chmod 0750 && \
  chown -R root:apache /srv/nextcloud && \
  chown -R apache:apache /srv/nextcloud/config && \
  chown -R apache:apache /srv/nextcloud/custom_apps && \
  chown -R apache:apache /srv/nextcloud/data

COPY httpd.conf /etc/apache2/conf.d/overrides.conf
COPY opcache.ini /etc/php5/conf.d/opcache_settings.ini

WORKDIR /srv/nextcloud

CMD httpd -DFOREGROUND
