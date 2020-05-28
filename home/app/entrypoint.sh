#!/usr/bin/env bash
echo "Running entrypoint script..."

set -e

# make sure Laravel can write its own files
mkdir -p /opt/app/storage/logs/
touch /opt/app/storage/logs/laravel.log
touch /opt/app/storage/logs/worker.log
chown www-data:www-data -R /opt/app/storage
chown www-data:www-data -R /opt/app/bootstrap/cache

cd /opt/app

# create storage symlink
echo "create storage symlink..."
su www-data -s /bin/sh -c "php artisan storage:link -q"

# startup commands
php /usr/local/bin/startup-commands.php | bash

exec "$@"
