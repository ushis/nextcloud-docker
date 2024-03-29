FROM alpine:3.15

# Hack to work around a bug (?) in iconv
#
# See https://github.com/docker-library/php/issues/240#issuecomment-305038173
RUN apk add \
  --no-cache \
  --repository http://dl-3.alpinelinux.org/alpine/edge/community \
  gnu-libiconv

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

RUN apk add --no-cache \
  apache2 \
  ca-certificates \
  curl \
  imagemagick \
  openssl \
  php7 \
  php7-apache2 \
  php7-apcu \
  php7-bcmath \
  php7-bz2 \
  php7-ctype \
  php7-curl \
  php7-dom \
  php7-fileinfo \
  php7-gd \
  php7-gmp \
  php7-iconv \
  php7-intl \
  php7-json \
  php7-ldap \
  php7-mbstring \
  php7-mcrypt \
  php7-opcache \
  php7-openssl \
  php7-pcntl \
  php7-pdo \
  php7-pdo_pgsql \
  php7-pecl-imagick \
  php7-pgsql \
  php7-posix \
  php7-session \
  php7-simplexml \
  php7-xml \
  php7-xmlreader \
  php7-xmlwriter \
  php7-zip \
  php7-zlib

COPY httpd.conf /etc/apache2/conf.d/overrides.conf
COPY apcu.ini /etc/php7/conf.d/apcu.ini
COPY memory.ini /etc/php7/conf.d/memory_settings.ini
COPY opcache.ini /etc/php7/conf.d/opcache_settings.ini
COPY nextcloud.asc /srv/nextcloud.asc

ARG NEXTCLOUD_VERSION

RUN apk add --no-cache gnupg && \
  curl -fLO "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2" && \
  curl -fLO "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2.asc" && \
  gpg --import /srv/nextcloud.asc && \
  gpg --verify "nextcloud-${NEXTCLOUD_VERSION}.tar.bz2.asc" "nextcloud-${NEXTCLOUD_VERSION}.tar.bz2" && \
  tar -C /srv -xjf "nextcloud-${NEXTCLOUD_VERSION}.tar.bz2" && \
  rm "nextcloud-${NEXTCLOUD_VERSION}.tar.bz2" "nextcloud-${NEXTCLOUD_VERSION}.tar.bz2.asc" && \
  apk del gnupg

COPY config/* /srv/nextcloud/config/

RUN mkdir -p /srv/nextcloud/data && \
  mkdir -p /srv/nextcloud/custom_apps && \
  find /srv/nextcloud -type f -print0 | xargs -0 chmod 0640 && \
  find /srv/nextcloud -type d -print0 | xargs -0 chmod 0750 && \
  chown -R root:apache /srv/nextcloud && \
  chown -R apache:apache /srv/nextcloud/config && \
  chown -R apache:apache /srv/nextcloud/custom_apps && \
  chown -R apache:apache /srv/nextcloud/data

WORKDIR /srv/nextcloud

CMD httpd -DFOREGROUND
