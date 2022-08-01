FROM php:7.4-apache

EXPOSE 80

ARG PATH_CONF_STORE=/etc/glpi
ARG PATH_DATA_STORE=/var/lib/glpi
ARG PATH_LOG_STORE=/var/log/glpi

RUN apt-get update

RUN apt-get upgrade -y

RUN apt-get install nano cron -y

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions gd xdebug mysqli intl

# Optional extensions
# RUN install-php-extensions ldap xmlrpc apcu
# cli domxlm openssl (find external)

# Before: extract glpi-{version}.tgz
COPY glpi/ /var/www/html

RUN mkdir -p /var/spool/cron/crontabs/
COPY configs/utils/cron-root /var/spool/cron/crontabs/root

RUN mkdir $PATH_DATA_STORE
RUN mkdir $PATH_CONF_STORE
RUN mkdir $PATH_LOG_STORE

RUN chown -R www-data:www-data /var/www/html/config
RUN chown -R www-data:www-data /var/www/html/marketplace

COPY configs/php/downstream.php /var/www/html/inc
COPY configs/php/.htaccess /var/www/html/install

WORKDIR /var/www/html

CMD ["cron"]