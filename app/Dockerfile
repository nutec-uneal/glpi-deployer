FROM php:8.2.7-apache-bookworm

# GLP URI (file, Link)
ARG GLPI_SOURCECODE_URI=glpi-10.0.9.tgz

# install-php-extensions URL
ARG INSTALL_PHP_EXT_URL=https://github.com/mlocati/docker-php-extension-installer/releases/download/2.1.16/install-php-extensions

# User and Group ID
ARG PUID=1024
ARG PGID=1024

# Config path "PHP" 
ARG PHP_CONF_PATH=/usr/local/etc


# Install and update apps
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

RUN rm -rf /etc/apache2/sites-enabled/* \
    /etc/apache2/sites-available/* \
    /var/log/apache2/*

WORKDIR /var/www/html

ADD ${GLPI_SOURCECODE_URI} /tmp
RUN ([ -d /tmp/glpi ] || tar -xf /tmp/glpi*.tgz -C /tmp) && \
    mv /tmp/glpi/* ./

RUN mkdir /utils && \
    mv /var/www/html/install /utils

COPY configs/app/downstream.php ./inc
COPY configs/php/php.ini ${PHP_CONF_PATH}/php
COPY configs/apache/sites-available/*.conf /etc/apache2/sites-available
COPY scripts/healthcheck.sh /

RUN groupadd -g ${PGID} app && \
    useradd -u ${PUID} -g app -G www-data -M -c applications -s /bin/bash app && \
    mkdir -m 755 /etc/glpi /var/lib/glpi /var/log/glpi && \
    chmod -R 755 ./ /utils /healthcheck.sh && \
    chown -R app:app ./ /utils /etc/glpi /var/lib/glpi /var/log/glpi && \
    sed -e "s/^: \${APACHE_RUN_USER:=www-data}/: \${APACHE_RUN_USER:=app}/" -i /etc/apache2/envvars && \
    sed -e "s/^: \${APACHE_RUN_GROUP:=www-data}/: \${APACHE_RUN_GROUP:=app}/" -i /etc/apache2/envvars && \
    echo "opcache.memory_consumption=256" >> ${PHP_CONF_PATH}/php/conf.d/docker-php-ext-opcache.ini

RUN a2ensite glpi.domain.conf

RUN a2enmod remoteip

RUN rm -rf /tmp/*


USER app

EXPOSE 80

VOLUME ["/var/www/html/marketplace", "/etc/glpi", "/var/lib/glpi", "/var/log/glpi", "/var/log/apache2"]

CMD ["apache2ctl", "-D", "FOREGROUND"]
