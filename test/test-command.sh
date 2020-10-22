#!/usr/bin/env bash
set -e 

# clean the app folder
cd /opt/
rm -rf app

# create laravel project into app
composer create-project --prefer-dist laravel/laravel app

# start services in the background
runsvdir /etc/service &

# check if the services are available
wait-for-it.sh --host=localhost --port=8080
