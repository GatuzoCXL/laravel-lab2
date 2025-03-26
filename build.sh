#!/usr/bin/env bash
# Exit on error
set -o errexit

composer install --optimize-autoloader --no-dev
php artisan config:cache
php artisan route:cache
php artisan migrate --force
