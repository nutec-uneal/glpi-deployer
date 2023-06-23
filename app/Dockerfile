FROM php:8.2-fpm-alpine3.18

ARG GLPI_SOURCECODE_URL=https://github.com/glpi-project/glpi/releases/download/10.0.7/glpi-10.0.7.tgz

# install-php-extensions download link
ARG INSTALL_PHP_EXT_URL=https://github.com/mlocati/docker-php-extension-installer/releases/download/2.1.16/install-php-extensions

# Config path "PHP" 
ARG PHP_CONF_PATH=/usr/local/etc

# User and Group ID
ARG PUID=1024
ARG PGID=1024

# Install system apps
RUN apk update

# PHP EXTENSIONS (dependencies)
ADD ${INSTALL_PHP_EXT_URL} /usr/local/bin
RUN chmod +x /usr/local/bin/install-php-extensions

RUN install-php-extensions gd \
    xdebug \
    mysqli \
    intl \
    ldap \
    xmlrpc \
    apcu \
    exif \
    bz2 \
    zip \
    opcache


WORKDIR /var/www/html

RUN rm -rf ${PHP_CONF_PATH}/php-fpm.d/*

ADD ${GLPI_SOURCECODE_URL} /tmp
RUN tar -xf /tmp/glpi*.tgz -C /tmp && \
    mv /tmp/glpi/* ./

COPY configs/app/local_define.php /etc/glpi
COPY config/app/downstream.php ./inc
COPY configs/php/php.ini ${PHP_CONF_PATH}/php
COPY configs/php/php-fpm.conf ${PHP_CONF_PATH}
COPY configs/php/php-fpm.d/*.conf ${PHP_CONF_PATH}/php-fpm.d

RUN addgroup -g ${PGID} app && \
    adduser -u ${PUID} -G ${PGID} -DH -g applications -s /bin/sh app && \
    mkdir -m 754 /run/php /var/lib/glpi /var/log/glpi /var/log/php-fpm && \
    chmod -R 754 ./ && \
    chown -R app:app ./ /run/php /etc/glpi /var/lib/glpi /var/log/glpi /var/log/php-fpm ./ && \
    echo "opcache.memory_consumption=256" >> ${PHP_CONF_PATH}/php/conf.d/docker-php-ext-opcache.ini &&

RUN rm -rf /tmp/*

#USER app

EXPOSE 9000
VOLUME [ "/var/www/html", "/var/www/html/marketplace", "/etc/glpi", "/var/lib/glpi", "/var/log/glpi", "/var/log/php-fpm" ]