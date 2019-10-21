FROM debian:stretch-slim
RUN apt-get update && apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
    curl zip unzip lynx-cur ssmtp rsyslog cron \
    apache2 libapache2-mod-php7.0 \
    php-pear \
    php7.0-curl \
    php7.0-memcached \
    php7.0-memcache \
    php7.0-mbstring \
    php7.0-mysql \
    php7.0-intl \
    php7.0-ldap \
    php7.0-xdebug \
    php7.0-soap \
    php7.0-gd \
    php7.0-imagick \
    php7.0-mcrypt \
    php7.0-opcache \
    php7.0-zip

ENV APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_PID_FILE=/var/run/apache2.pid 

COPY ./rootfs /
RUN chmod +x /entrypoint.sh

RUN a2enmod remoteip && a2enconf remoteip && a2enmod php7.0 && a2enmod rewrite 

RUN usermod -u 1000 www-data
# Имя пользователя
#RUN usermod -c "" www-data
#RUN usermod -c "" root

WORKDIR /var/www/html
EXPOSE 80

CMD /usr/sbin/apache2ctl -D FOREGROUND
