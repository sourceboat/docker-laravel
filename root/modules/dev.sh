#!/usr/bin/env bash
cd /opt/app

echo "Build development..."
composer install --prefer-dist --no-progress --no-interaction
yarn