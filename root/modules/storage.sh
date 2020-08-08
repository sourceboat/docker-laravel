#!/usr/bin/env bash
cd /opt/app

echo "Create storage symlink..."
su www-data -s /bin/sh -c "php artisan storage:link -q"