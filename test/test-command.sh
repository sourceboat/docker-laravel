#!/usr/bin/env bash

set -e 

# Clean the app folder
cd /opt/
rm -rf app

# Create laravel project into app
composer create-project --prefer-dist laravel/laravel app

# Start services in the background.
runsvdir /etc/service &

# Check if the Services are available
wait-for-it.sh --host=localhost --port=8080