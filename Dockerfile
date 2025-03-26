FROM php:8.2-apache

# Instalar extensiones de PHP necesarias
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    zip \
    unzip

# Instalar extensiones de PHP
RUN docker-php-ext-install pdo pdo_pgsql pgsql mbstring exif pcntl bcmath gd

# Habilitar mod_rewrite para Apache
RUN a2enmod rewrite

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establecer COMPOSER_ALLOW_SUPERUSER para evitar advertencias
ENV COMPOSER_ALLOW_SUPERUSER=1

# Configurar directorio de trabajo
WORKDIR /var/www/html

# Crear un nuevo proyecto Laravel
RUN composer create-project --prefer-dist laravel/laravel:^10.0 .

# Crear un archivo .env básico
RUN cp .env.example .env && \
    php artisan key:generate

# Asegurarse de que la configuración de logs es correcta
RUN sed -i "s/LOG_CHANNEL=stack/LOG_CHANNEL=stderr/g" .env

# Copiar archivos personalizados (si existen)
COPY . /tmp/app-files/
RUN if [ -d "/tmp/app-files/" ]; then \
    cp -rf /tmp/app-files/* . 2>/dev/null || true; \
    cp -rf /tmp/app-files/.* . 2>/dev/null || true; \
    fi

# Instalar dependencias nuevamente
RUN composer install --no-interaction --no-dev --optimize-autoloader

# Configurar permisos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Exponer puerto 80
EXPOSE 80

# Configurar virtualhost de Apache
RUN { \
    echo '<VirtualHost *:80>'; \
    echo '    DocumentRoot /var/www/html/public'; \
    echo '    <Directory /var/www/html/public>'; \
    echo '        AllowOverride All'; \
    echo '        Require all granted'; \
    echo '    </Directory>'; \
    echo '</VirtualHost>'; \
} > /etc/apache2/sites-available/000-default.conf

# Script para ejecutar al iniciar el contenedor
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# Iniciar Apache en primer plano
CMD ["apache2-foreground"]
