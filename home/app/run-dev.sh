#!/usr/bin/env bash
echo "Running via DEV script..."
cd /home/app

# Make sure Laravel can write its own files
mkdir -p /home/app/storage/logs/
touch /home/app/storage/logs/laravel.log
touch /home/app/storage/logs/worker.log
chown www-data:www-data -R /home/app/storage
chown www-data:www-data -R /home/app/bootstrap/cache

# install dependencies
composer install --prefer-dist --no-progress --no-interaction
yarn

# migrate and setup database
wait-for-it.sh mysql:3306
php artisan migrate --force

# start the services
exec runsvdir /etc/service
