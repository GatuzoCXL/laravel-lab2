#!/bin/bash
set -e

# Crear archivo .env si no existe
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Configurar APP_KEY si no está definido
if [ -z "$APP_KEY" ]; then
    echo "Generating new APP_KEY"
    php artisan key:generate
else
    # Establecer APP_KEY desde variable de entorno
    sed -i "s|APP_KEY=.*|APP_KEY=$APP_KEY|g" .env
fi

# Configurar variables de entorno adicionales
[ ! -z "$APP_NAME" ] && sed -i "s|APP_NAME=.*|APP_NAME=$APP_NAME|g" .env
[ ! -z "$APP_ENV" ] && sed -i "s|APP_ENV=.*|APP_ENV=$APP_ENV|g" .env
[ ! -z "$APP_DEBUG" ] && sed -i "s|APP_DEBUG=.*|APP_DEBUG=$APP_DEBUG|g" .env
[ ! -z "$APP_URL" ] && sed -i "s|APP_URL=.*|APP_URL=$APP_URL|g" .env
[ ! -z "$LOG_CHANNEL" ] && sed -i "s|LOG_CHANNEL=.*|LOG_CHANNEL=$LOG_CHANNEL|g" .env

# Configurar base de datos si DATABASE_URL está definido
if [ ! -z "$DATABASE_URL" ]; then
    echo "DATABASE_URL=$DATABASE_URL" >> .env
fi

# Caché de configuración
php artisan config:clear
php artisan config:cache
php artisan route:cache

# Ejecutar migraciones si estamos conectados a la base de datos
if [ ! -z "$DATABASE_URL" ]; then
    echo "Running database migrations..."
    php artisan migrate --force
fi

# Ejecutar comando pasado como argumento
exec "$@"
