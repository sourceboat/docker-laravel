#!/usr/bin/env bash
echo "Running entrypoint script..."

set -e

# make sure Laravel can write its own files
mkdir -p /opt/app/storage/logs/
touch /opt/app/storage/logs/laravel.log
touch /opt/app/storage/logs/worker.log
chown www-data:www-data -R /opt/app/storage
chown www-data:www-data -R /opt/app/bootstrap/cache

# startup commands
echo "Running startup commands..."
php /usr/local/bin/startup-commands.php | bash

if [[ -n "$DB_HOST" || -n "$DB_PORT" ]]; then
  wait-for-it.sh --host=$DB_HOST --port=$DB_PORT
fi

exec "$@"
