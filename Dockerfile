FROM alexcheng/apache2-php7:7.1.11

MAINTAINER Fu Cheng <alexcheng1982@gmail.com>

RUN a2enmod rewrite

ENV MAGENTO_VERSION 2.2.1

RUN rm -rf /var/www/html/* \
    && apt-get update \
    && apt-get install -y wget

RUN cd /tmp && curl https://codeload.github.com/magento/magento2/tar.gz/$MAGENTO_VERSION -o $MAGENTO_VERSION.tar.gz && tar xvf $MAGENTO_VERSION.tar.gz && mv magento2-$MAGENTO_VERSION/* magento2-$MAGENTO_VERSION/.htaccess /var/www/html


RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer
RUN requirements="libpng12-dev libmcrypt-dev libmcrypt4 libcurl3-dev libfreetype6 libjpeg-turbo8 libjpeg-turbo8-dev libpng12-dev libfreetype6-dev libicu-dev libxslt1-dev" \
    && apt-get install -y $requirements \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install zip \
    && docker-php-ext-install intl \
    && docker-php-ext-install xsl \
    && docker-php-ext-install soap \
    && requirementsToRemove="libpng12-dev libmcrypt-dev libcurl3-dev libpng12-dev libfreetype6-dev libjpeg-turbo8-dev" \
    && apt-get purge --auto-remove -y $requirementsToRemove

COPY ./auth.json /var/www/.composer/
RUN chsh -s /bin/bash www-data
RUN chown -R www-data:www-data /var/www
RUN su www-data -c "cd /var/www/html && composer install"
RUN cd /var/www/html \
    && find . -type d -exec chmod 770 {} \; \
    && find . -type f -exec chmod 660 {} \; \
    && chmod u+x bin/magento


RUN su www-data -c "cd /var/www/html && composer config repositories.magento composer https://repo.magento.com/"


COPY ./bin/install-magento /usr/local/bin/install-magento
RUN chmod +x /usr/local/bin/install-magento

COPY ./bin/install-sampledata /usr/local/bin/install-sampledata
RUN chmod +x /usr/local/bin/install-sampledata

RUN echo "memory_limit=1024M" > /usr/local/etc/php/conf.d/memory-limit.ini

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Commented out the next 3 lines, because i don't see no use of this
WORKDIR /var/www/html
#VOLUME /var/www/html/var
#VOLUME /var/www/html/pub

# Add cron job
ADD crontab /etc/cron.d/magento2-cron
RUN chmod 0644 /etc/cron.d/magento2-cron \
    && crontab -u www-data /etc/cron.d/magento2-cron