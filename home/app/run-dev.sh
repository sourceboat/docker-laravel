#!/usr/bin/env bash
echo "Running via DEV script..."
cd /opt/app

# create storage symlink
php artisan storage:link

# install dependencies
composer install --prefer-dist --no-progress --no-interaction
yarn

# migrate and setup database
wait-for-it.sh mysql:3306
php artisan migrate --force
php artisan setup

# start the services
exec runsvdir /etc/service
