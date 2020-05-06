#!/usr/bin/env bash
echo "Running via PROD script..."
cd /opt/app

# migrate and setup database
wait-for-it.sh mysql:3306
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
