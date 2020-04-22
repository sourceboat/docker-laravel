#!/usr/bin/env bash
echo "Running via DEV script..."
cd /opt/app

# make sure Laravel can write its own files
mkdir -p /opt/app/storage/logs/
touch /opt/app/storage/logs/laravel.log
touch /opt/app/storage/logs/worker.log
chown www-data:www-data -R /opt/app/storage
chown www-data:www-data -R /opt/app/bootstrap/cache

# create storage symlink
php artisan storage:link

# install dependencies
composer install --prefer-dist --no-progress --no-interaction
yarn

# migrate and setup database
if [ -z "$DB_HOST" ]; then
  wait-for-it.sh $DB_HOST
fi
php artisan migrate --force
php artisan setup

# start the services
exec runsvdir /etc/service
