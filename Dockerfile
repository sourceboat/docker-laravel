FROM php:7.3.8-fpm-alpine3.10

ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="0" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"

RUN apk info \
    && echo @edge http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories \
    && echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories \
    && echo @3.9 http://dl-cdn.alpinelinux.org/alpine/v3.9/main >> /etc/apk/repositories \
    && apk update \
    && apk upgrade \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
    && apk add --no-cache \
        sudo \
        runit \
        nginx \
        zlib-dev \
        icu-dev \
        imagemagick \
        imagemagick-dev \
        libzip-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libxml2-dev \
        freetype-dev \
        bash \
        git \
        nodejs \
        composer \
        php7-tokenizer \
        php7-simplexml \
        php7-dom \
        mysql-client \
        yarn@edge \
        xvfb \
        chromium@3.9 \
        chromium-chromedriver@3.9 \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo_mysql \
        zip \
        bcmath \
        exif \
        intl \
        opcache \
        pcntl \
        mbstring \
        iconv \
    && pecl install \
        redis \
        imagick \
    && docker-php-ext-enable \
        redis \
        imagick \
    && apk del .build-deps

# fix iconv (see https://github.com/docker-library/php/issues/240#issuecomment-305038173)
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# change default shell
SHELL ["/bin/bash", "-c"]

# create app user
RUN addgroup -S app && \
    adduser -S app -G app && \
    echo "app ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# create working dir
RUN mkdir /opt/app
WORKDIR /opt/app

# install wait-for-it
ADD https://github.com/vishnubob/wait-for-it/raw/master/wait-for-it.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wait-for-it.sh

# copy runit services
COPY ./etc/service/ /etc/service/
RUN find /etc/service/ -name "run" -exec chmod -v +x {} \;

# copy nginx config files
COPY ./etc/nginx/ /etc/nginx/

# copy php config files
COPY ./usr/local/etc/php/ /usr/local/etc/php/
COPY ./usr/local/etc/php-fpm.d/ /usr/local/etc/php-fpm.d/

# configure composer
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_MEMORY_LIMIT=-1
ENV PATH="$PATH:/opt/app/vendor/bin:~/.composer/vendor/bin"
RUN composer global require hirak/prestissimo

# configure yarn
RUN yarn config set strict-ssl false && \
    yarn global add cross-env

# copy home folder and make run scripts executable
COPY ./home/app/ /home/app/
COPY ./root/.bashrc /root/
RUN find /home/app -name "run-*.sh" -exec chmod -v +x {} \;

# run the application
CMD /home/app/run-dev.sh
EXPOSE 8080
