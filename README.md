# docker-laravel `WIP`

[![Docker Build Status](https://img.shields.io/docker/cloud/build/sourceboat/docker-laravel.svg?style=flat-square)](https://hub.docker.com/r/sourceboat/docker-laravel/builds/)
[![Release](https://img.shields.io/github/release/sourceboat/docker-laravel.svg?style=flat-square)](https://github.com/sourceboat/docker-laravel/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/sourceboat/docker-laravel.svg?style=flat-square)](https://hub.docker.com/r/sourceboat/docker-laravel/)
[![Image Size](https://img.shields.io/docker/image-size/sourceboat/docker-laravel?style=flat-square)](https://microbadger.com/images/sourceboat/docker-laravel)
[![MicroBadger Layers](https://img.shields.io/microbadger/layers/sourceboat/docker-laravel.svg?style=flat-square)](https://microbadger.com/images/sourceboat/docker-laravel)

A highly opinionated docker image which aims to be perfectly suited to run our Laravel applications.

## What's included?

`WIP`

## Usage

### Development 

Create a `Dockerfile` with the following contents (and adjust version tag):

```dockerfile
FROM sourceboat/docker-laravel:x.x.x

# install yarn dependencies
COPY package.json yarn.* ./
RUN yarn install --pure-lockfile

# copy application
COPY . ./

# install composer dependencies
RUN composer install -d /opt/app --prefer-dist --no-progress --no-interaction --optimize-autoloader

# create storage symlink
RUN php artisan storage:link

# build assets
RUN yarn production
```

Create a `docker-compose.yml` with the following contents:

```yml
version: '3.7'
services:
  app:
    build: .
    restart: unless-stopped
    environment:
      - PHP_OPCACHE_VALIDATE_TIMESTAMPS=1
      - PHP_MEMORY_LIMIT=1G
      - PHP_MAX_EXECUTION_TIME=30
      - STARTUP_COMMAND1=/root/modules/dev.sh
      - STARTUP_COMMAND2=php artisan migrate --force
      - STARTUP_COMMAND3=php artisan setup
    volumes:
      - ./:/opt/app:cached
    ports:
      - "8080:8080"
    depends_on:
      - mysql
  mysql:
    image: mysql:8.0
    environment:
      - "MYSQL_ROOT_PASSWORD=secret"
      - "MYSQL_DATABASE=default"
```

Add more services (e.g. `redis`) if needed.

Make sure to adjust your `.env` accordingly and set `APP_URL` to `http://localhost:8080`.

Run `docker-compose up` to start the services.

### Startup Commands

Further commands can be defined via ENV variable `STARTUP_COMMANDXXX`, which are executed at container start before the actual command.

The commands must be numbered sequentially and start with 1 (e.g. `STARTUP_COMMAND1=command`, `STARTUP_COMMAND2=...`).

```yml
version: '3.7'
services:
  app:
    image: sourceboat/docker-laravel
    restart: unless-stopped
    environment:
      - PHP_OPCACHE_VALIDATE_TIMESTAMPS=1
      - PHP_MEMORY_LIMIT=1G
      - PHP_MAX_EXECUTION_TIME=30
      - STARTUP_COMMAND1=/root/modules/storage.sh
      - STARTUP_COMMAND2=/root/modules/cache.sh
      - STARTUP_COMMAND3=php artisan migrate --force
      - STARTUP_COMMAND4=php artisan horizon:restart
    volumes:
      - ./:/opt/app:cached
    ports:
      - "8080:8080"
    depends_on:
      - mysql
  mysql:
    image: mysql:8.0
    environment:
      - "MYSQL_ROOT_PASSWORD=secret"
      - "MYSQL_DATABASE=default"
```

### Production

`WIP`

## Changelog

Check [releases](https://github.com/sourceboat/docker-laravel/releases) for all notable changes.

## Credits

- [Phil-Bastian Berndt](https://github.com/pehbehbeh)
- [Philipp Kübler](https://github.com/PKuebler)
- [Kevin Buchholz](https://github.com/NeroAzure)
- [All Contributors](https://github.com/sourceboat/docker-laravel/graphs/contributors)

## License

The MIT License (MIT). Please see [License File](LICENSE.md) for more information.
