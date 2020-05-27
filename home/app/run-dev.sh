#!/usr/bin/env bash
echo "Running via DEV script..."
cd /opt/app

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
