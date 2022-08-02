FROM php:7.4-apache

EXPOSE 80

ARG PATH_CONF_STORE=/etc/glpi
ARG PATH_DATA_STORE=/var/lib/glpi
ARG PATH_LOG_STORE=/var/log/glpi

RUN apt-get update

RUN apt-get upgrade -y

RUN apt-get install nano -y

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    /usr/local/bin/

# EXTENSIONS
RUN chmod +x /usr/local/bin/install-php-extensions

# Required
RUN install-php-extensions gd xdebug mysqli intl
# Optional 
RUN install-php-extensions ldap xmlrpc apcu exif bz2 zip opcache 

# Before: extract glpi-{version}.tgz
COPY glpi/ /var/www/html

RUN mkdir $PATH_DATA_STORE
RUN mkdir $PATH_CONF_STORE
RUN mkdir $PATH_LOG_STORE

RUN chown -R www-data:www-data /var/www/html/config
RUN chown -R www-data:www-data /var/www/html/marketplace

COPY configs/php/downstream.php /var/www/html/inc
COPY configs/php/.htaccess /var/www/html/install

WORKDIR /var/www/html
