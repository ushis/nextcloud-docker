FROM alpine:3.5

RUN apk add --no-cache \
  apache2 \
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
  php5-openssl \
  php5-pdo \
  php5-pdo_pgsql \
  php5-pgsql \
  php5-posix \
  php5-xml \
  php5-xmlreader \
  php5-zip \
  php5-zlib

RUN curl -L https://download.nextcloud.com/server/releases/nextcloud-11.0.2.tar.bz2 | \
    tar -C /srv -xjf - && \
  chown -R root:www-data /srv/nextcloud && \
  find /srv/nextcloud -type d -exec chmod 0750 {} \; && \
  find /srv/nextcloud -type f -exec chmod 0640 {} \;

COPY httpd.conf /etc/apache2/conf.d/overrides.conf

CMD httpd -DFOREGROUND
