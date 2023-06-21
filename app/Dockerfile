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

RUN addgroup -g ${PGID} app && \
    adduser -u ${PUID} -G ${PGID} -DH -g applications -s /bin/sh app && \
    mkdir -m 754 /etc/glpi /var/lib/glpi /var/log/glpi && \
    chown -R app:app /etc/glpi /var/lib/glpi /var/log/glpi

COPY configs/php/php.ini ${PHP_CONF_PATH}/php/php.ini

RUN echo "opcache.memory_consumption=256" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    sed -e 's/^;?[ ]*session.cookie_httponly[ ]*=.*/session.cookie_httponly = on/' -i /usr/local/etc/php/php.ini

ADD ${GLPI_SOURCECODE_URL} /tmp
RUN tar -xf /tmp/glpi-10.0.7.tgz -C /tmp && \
    mv /tmp/glpi/* /var/www/html

COPY config/app/downstream.php /var/www/html/inc

# Config: files permission
RUN chown -R www-data:www-data /var/www/html/config
RUN chown -R www-data:www-data /var/www/html/marketplace

WORKDIR /var/www/html

EXPOSE 80
