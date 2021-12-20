FROM php:8.1.1-fpm-alpine

ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="0" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10" \
    PHP_MEMORY_LIMIT="512M" \
    PHP_MAX_EXECUTION_TIME="60" \
    PHP_FPM_MAX_CHILDREN="100" \
    PHP_FPM_MAX_REQUESTS="1000" \
    PHP_FPM_PM="ondemand" \
    PHP_FPM_PROCESS_IDLE_TIMEOUT="10s"

RUN apk info \
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
        libzip-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libxml2-dev \
        freetype-dev \
        bash \
        git \
        nodejs \
        npm \
        composer \
        mysql-client \
        mariadb-connector-c \
        php8-dom \
        php8-tokenizer \
        php8-xml \
        php8-xmlwriter \
        php8-fileinfo \
        yarn \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo_mysql \
        zip \
        bcmath \
        exif \
        intl \
        opcache \
        pcntl \
        iconv \
        xml \
        xmlwriter \
        dom \
        tokenizer \
        fileinfo \
    && pecl install \
        redis \
    && docker-php-ext-enable redis \
    && apk del .build-deps \
    && rm -rf /tmp/* /var/cache/apk/* 

# fix iconv (see https://github.com/docker-library/php/issues/240#issuecomment-876464325)
RUN apk add gnu-libiconv=1.15-r3 --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so

# change default shell
SHELL ["/bin/bash", "-c"]

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
COPY ./etc/nginx/conf.d/ /etc/nginx/conf.d/
COPY ./etc/nginx/nginx.conf /etc/nginx/nginx.conf

# copy php config files
COPY ./usr/local/etc/php/ /usr/local/etc/php/
COPY ./usr/local/etc/php-fpm.d/ /usr/local/etc/php-fpm.d/

# copy bin files
COPY ./usr/local/bin/startup-commands.php /usr/local/bin/

# configure composer
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_MEMORY_LIMIT=-1 \
    PATH="$PATH:/opt/app/vendor/bin:~/.composer/vendor/bin"

# configure yarn
RUN yarn config set strict-ssl false && \
    yarn global add cross-env

# copy root folder and make run scripts executable
COPY ./root/ /root/
RUN find /root -name "*.sh" -exec chmod -v +x {} \;

# run the application
ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["runsvdir", "/etc/service"]
EXPOSE 8080
