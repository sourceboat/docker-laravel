#!/usr/bin/env bash
echo "Running via DEV script..."
cd /opt/app

# Make sure Laravel can write its own files
mkdir -p /opt/app/storage/logs/
touch /opt/app/storage/logs/laravel.log
touch /opt/app/storage/logs/worker.log
chown www-data:www-data -R /opt/app/storage
chown www-data:www-data -R /opt/app/bootstrap/cache

# install dependencies
composer install --prefer-dist --no-progress --no-interaction
yarn

# migrate and setup database
wait-for-it.sh mysql:3306
php artisan migrate --force

# start the services
exec runsvdir /etc/service
