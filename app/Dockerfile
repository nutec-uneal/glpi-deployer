FROM php:8.1-apache

EXPOSE 80

# Install system apps
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install cron supervisor -y

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

RUN sed -e 's/session.cookie_httponly =.*/session.cookie_httponly = on/' -i /usr/local/etc/php/php.ini

### Config: Apache
COPY configs/apache2/sites-available/glpi.domain.conf /etc/apache2/sites-available/

RUN rm /etc/apache2/sites-enabled/*
RUN a2ensite glpi.domain.conf

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
RUN mkdir /etc/glpi
RUN mkdir /var/lib/glpi
RUN mkdir /var/log/glpi

# Config: set app files
COPY configs/php/downstream.php /var/www/html/inc

# Config: files permission
RUN chown -R www-data:www-data /var/www/html/config
RUN chown -R www-data:www-data /var/www/html/marketplace

WORKDIR /var/www/html

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
