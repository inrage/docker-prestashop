ARG PHP_VERSION=7.4

FROM debian:bookworm-slim

ARG PHP_VERSION
ENV PHP_VERSION=${PHP_VERSION}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       curl \
       gnupg \
    && curl -fsSL https://packages.sury.org/php/apt.gpg \
       | gpg --dearmor -o /etc/apt/keyrings/sury.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/sury.gpg] https://packages.sury.org/php/ bookworm main" \
       > /etc/apt/sources.list.d/sury.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       apache2 \
       libapache2-mod-php${PHP_VERSION} \
       php${PHP_VERSION} \
       php${PHP_VERSION}-bcmath \
       php${PHP_VERSION}-curl \
       php${PHP_VERSION}-dom \
       php${PHP_VERSION}-fileinfo \
       php${PHP_VERSION}-gd \
       php${PHP_VERSION}-iconv \
       php${PHP_VERSION}-intl \
       php${PHP_VERSION}-mbstring \
       php${PHP_VERSION}-mysql \
       php${PHP_VERSION}-opcache \
       php${PHP_VERSION}-simplexml \
       php${PHP_VERSION}-soap \
       php${PHP_VERSION}-xml \
       php${PHP_VERSION}-zip \
       php${PHP_VERSION}-memcached \
       php${PHP_VERSION}-redis \
    && if dpkg --compare-versions "${PHP_VERSION}" lt "8.0"; then \
         apt-get install -y --no-install-recommends php${PHP_VERSION}-json; \
       fi \
    && a2enmod rewrite headers deflate expires ssl remoteip \
    && a2dissite 000-default \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY config/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY config/apache/security.conf /etc/apache2/conf-available/security.conf
COPY config/apache/remoteip.conf /etc/apache2/conf-available/remoteip.conf
COPY config/apache/deflate.conf /etc/apache2/conf-available/deflate.conf
COPY config/apache/expires.conf /etc/apache2/conf-available/expires.conf

RUN a2ensite 000-default \
    && a2enconf security remoteip deflate expires

COPY config/php/prestashop.ini /etc/php/${PHP_VERSION}/apache2/conf.d/99-prestashop.ini

RUN printf '#!/bin/bash\nset -e\n. /etc/apache2/envvars\nexec apache2 -DFOREGROUND "$@"\n' \
    > /usr/local/bin/apache2-foreground \
    && chmod +x /usr/local/bin/apache2-foreground

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

WORKDIR /var/www/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:80/ || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
