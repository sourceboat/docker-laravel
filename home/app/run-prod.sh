#!/usr/bin/env bash
echo "Running via PROD script..."
cd /opt/app

# make sure Laravel can write its own files
mkdir -p /opt/app/storage/logs/
touch /opt/app/storage/logs/laravel.log
touch /opt/app/storage/logs/worker.log
chown www-data:www-data -R /opt/app/storage
chown www-data:www-data -R /opt/app/bootstrap/cache

# migrate and setup database
if [ -z "$DB_HOST" ]; then
  wait-for-it.sh $DB_HOST
fi
php artisan migrate --force
php artisan setup

# build caches
php artisan config:cache
php artisan route:cache
php artisan view:cache

# restart the Horizon supervisors
php artisan horizon:restart

# start the services
exec runsvdir /etc/service
