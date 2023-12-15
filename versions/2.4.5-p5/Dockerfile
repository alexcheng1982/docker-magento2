FROM ghcr.io/alexcheng1982/docker-apache2-php8:8.1

LABEL maintainer="alexcheng1982@gmail.com"
LABEL php_version="8.1"
LABEL magento_version="2.4.5-p5"
LABEL description="Magento Open Source 2.4.5-p5 with PHP 8.1"

ENV MAGENTO_VERSION 2.4.5-p5
ENV INSTALL_DIR /var/www/html
ENV COMPOSER_HOME /var/www/.composer/

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer
COPY ./auth.json $COMPOSER_HOME

RUN requirements="libpng++-dev libzip-dev libmcrypt-dev libmcrypt4 libcurl3-dev libfreetype6 libjpeg-turbo8 libjpeg-turbo8-dev libfreetype6-dev libicu-dev libxslt1-dev zip unzip libxml2 libonig-dev" \
    set -eux; \
    apt-get update; \
    apt-get install -y $requirements; \
    rm -rf /var/lib/apt/lists/* 

RUN set -eux; \
    docker-php-ext-install pdo_mysql; \
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-install gd; \
    docker-php-ext-install mbstring; \
    docker-php-ext-install zip; \
    docker-php-ext-install intl; \
    docker-php-ext-install xsl; \
    docker-php-ext-install soap; \
    docker-php-ext-install sockets; \
    docker-php-ext-install bcmath

RUN yes '' | pecl install mcrypt-1.0.6 \
    && echo 'extension=mcrypt.so' > /usr/local/etc/php/conf.d/mcrypt.ini

RUN chsh -s /bin/bash www-data

RUN chown -R www-data:www-data /var/www

RUN su www-data -c "composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition $INSTALL_DIR $MAGENTO_VERSION"

RUN cd $INSTALL_DIR \
    && find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} + \
    && find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} + \
    && chown -R :www-data . \
    && chmod u+x bin/magento

COPY ./install-magento /usr/local/bin/install-magento
RUN chmod +x /usr/local/bin/install-magento

COPY ./install-sampledata /usr/local/bin/install-sampledata
RUN chmod +x /usr/local/bin/install-sampledata

RUN a2enmod rewrite
RUN echo "memory_limit=2048M" > /usr/local/etc/php/conf.d/memory-limit.ini

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR $INSTALL_DIR

VOLUME $INSTALL_DIR