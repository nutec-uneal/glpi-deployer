FROM php:8.2-apache-bookworm

ARG GLPI_SOURCECODE_URL=glpi-10.0.7.tgz

# install-php-extensions download link
ARG INSTALL_PHP_EXT_URL=https://github.com/mlocati/docker-php-extension-installer/releases/download/2.1.16/install-php-extensions

# Config path "PHP" 
ARG PHP_CONF_PATH=/usr/local/etc

# User and Group ID
ARG PUID=1024
ARG PGID=1024

# Install system apps
RUN apt-get update -y

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

RUN rm -rf /etc/apache2/sites-enabled/* /etc/apache2/sites-available/*

WORKDIR /var/www/html

ADD ${GLPI_SOURCECODE_URL} /tmp
RUN mv /tmp/glpi/* ./

COPY configs/app/downstream.php ./inc
COPY configs/php/php.ini ${PHP_CONF_PATH}/php
COPY configs/apache/sites-available/*.conf /etc/apache2/sites-available

RUN groupadd -g ${PGID} app && \
    useradd -u ${PUID} -g app -M -c applications -s /bin/bash app && \
    mkdir -m 755 /etc/glpi /var/lib/glpi /var/log/glpi && \
    chmod -R 755 ./ && \
    chown -R app:app ./ /etc/glpi /var/lib/glpi /var/log/glpi /var/log/apache2 && \
    echo "opcache.memory_consumption=256" >> ${PHP_CONF_PATH}/php/conf.d/docker-php-ext-opcache.ini

RUN a2ensite glpi.domain.conf

RUN a2enmod remoteip

RUN rm -rf /tmp/*

EXPOSE 80

#USER app

VOLUME ["/var/www/html/marketplace", "/etc/glpi", "/var/lib/glpi", "/var/log/glpi", "/var/log/apache2" ]