FROM php:7.1-apache
RUN apt-get update && apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    mysql-client \
    libwebp-dev libjpeg62-turbo-dev libpng-dev libxpm-dev \
    libfreetype6-dev
#     curl zip unzip lynx-cur ssmtp rsyslog cron \
#     apache2 libapache2-mod-php7.0 \
#     php-pear \
#     php-curl \
#     php-memcached \
#     php-memcache \
#     php-mbstring \
#     php-mysql \
#     php-intl \
#     php-ldap \
#     php-xdebug \
#     php-soap \
#     php-gd \
#     php-imagick \
#     php-mcrypt \
#     php-opcache \
#     php-zip

# ENV APACHE_RUN_USER=www-data \
#     APACHE_RUN_GROUP=www-data \
#     APACHE_LOG_DIR=/var/log/apache2 \
#     APACHE_LOCK_DIR=/var/lock/apache2 \
#     APACHE_RUN_DIR=/var/run/apache2 \
#     APACHE_PID_FILE=/var/run/apache2.pid 
RUN docker-php-ext-install -j$(nproc) iconv mysqli mbstring opcache \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# RUN docker-php-ext-configure gd --with-gd --with-webp-dir --with-jpeg-dir \
#     --with-png-dir --with-zlib-dir --with-xpm-dir --with-freetype-dir \
#     --enable-gd-native-ttf

# RUN docker-php-ext-install mysqli gd

COPY ./rootfs /
# RUN chmod +x /entrypoint.sh

# RUN a2enmod remoteip && a2enconf remoteip && a2enmod php7.0 && a2enmod rewrite 

RUN usermod -u 1000 www-data
# Имя пользователя
#RUN usermod -c "" www-data
#RUN usermod -c "" root

# WORKDIR /var/www/html
# EXPOSE 80

# CMD /usr/sbin/apache2ctl -D FOREGROUND
