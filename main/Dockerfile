FROM php:7.4-apache

EXPOSE 80

# Variables (default values)
ARG PATH_CONF_STORE=/etc/glpi
ARG PATH_DATA_STORE=/var/lib/glpi
ARG PATH_LOG_STORE=/var/log/glpi

# Install system apps
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install nano cron supervisor -y

# PHP EXTENSIONS (dependencies)
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions

## Required
RUN install-php-extensions gd xdebug mysqli intl
## Optional 
RUN install-php-extensions ldap xmlrpc apcu exif bz2 zip opcache

## Config: parameters ".ini"

### Config: OPCache
RUN echo "opcache.memory_consumption=256" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
### Config: "php.ini" mode (default "production", alternative "development")
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

# Copy GLPI app to container
COPY glpi/ /var/www/html
RUN rm -rf /var/www/html/install/*

# Config: supervisord
RUN mkdir -p /var/log/supervisor
COPY configs/utils/supervisord.conf /etc/supervisord.conf

# Config: cron
COPY configs/utils/cron-task /etc/cron.d/cron-task
RUN chmod 600 /etc/cron.d/cron-task
RUN crontab /etc/cron.d/cron-task

# Config: GLPI data folders
RUN mkdir $PATH_DATA_STORE
RUN mkdir $PATH_CONF_STORE
RUN mkdir $PATH_LOG_STORE

# Config: set app files
COPY configs/php/downstream.php /var/www/html/inc

# Config: files permission
RUN chown -R www-data:www-data /var/www/html/config
RUN chown -R www-data:www-data /var/www/html/marketplace

WORKDIR /var/www/html

CMD ["/usr/bin/supervisord"]
