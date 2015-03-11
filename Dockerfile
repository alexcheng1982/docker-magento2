FROM php:5.6.6-apache

MAINTAINER Alex Cheng <alexcheng1982@gmail.com>

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

RUN requirements="libpng12-dev libmcrypt-dev libmcrypt4 libcurl3-dev libfreetype6 libjpeg62-turbo libpng12-dev libfreetype6-dev libjpeg62-turbo-dev" \
    && apt-get update && apt-get install -y $requirements && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install zip \
    && requirementsToRemove="libpng12-dev libmcrypt-dev libcurl3-dev libpng12-dev libfreetype6-dev libjpeg62-turbo-dev" \
    && apt-get purge --auto-remove -y $requirementsToRemove

RUN usermod -u 1000 www-data
RUN a2enmod rewrite

RUN apt-get update && apt-get install -y git
RUN rm -rf /var/www/html/*
RUN git clone https://github.com/magento/magento2.git /var/www/html
RUN chown -R www-data:www-data /var/www/html
RUN find /var/www/html -type d -exec chmod 700 {} \; && find . -type f -exec chmod 600 {} \;
RUN chsh -s /bin/bash www-data
RUN su www-data && cd /var/www/html && composer install

COPY ./bin/install-magento /usr/local/bin/install-magento
RUN chmod +x /usr/local/bin/install-magento
