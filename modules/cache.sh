#!/usr/bin/env bash

cd /opt/app

# build caches
echo "Build caches..."
php artisan config:cache
php artisan route:cache
php artisan view:cache