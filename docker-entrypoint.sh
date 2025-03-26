#!/bin/bash
set -e

# Si existe la variable APP_KEY, usarla
if [ -z "$APP_KEY" ]; then
    echo "Generating new APP_KEY"
    php artisan key:generate --show
fi

# Caché de configuración
php artisan config:cache
php artisan route:cache

# Ejecutar migraciones si estamos conectados a la base de datos
if [ ! -z "$DATABASE_URL" ]; then
    echo "Running database migrations..."
    php artisan migrate --force
fi

# Ejecutar comando pasado como argumento
exec "$@"
