# ---- Build Stage ----
    FROM composer:2.7 as composer

    # Copy composer files
    WORKDIR /app
    COPY composer.json composer.lock ./
    RUN composer install --no-dev --no-scripts --no-interaction
    
    # ---- Runtime Stage ----
    FROM php:8.2-fpm-alpine
    
    # Install system dependencies
    RUN apk add --no-cache \
        nginx \
        curl \
        bash \
        libpng-dev \
        libzip-dev \
        oniguruma-dev \
        icu-dev \
        zlib-dev \
        libxml2-dev \
        freetype-dev \
        && docker-php-ext-install pdo pdo_mysql mbstring zip exif pcntl bcmath intl xml
    
    # Install Composer (from build stage)
    COPY --from=composer /usr/bin/composer /usr/bin/composer
    
    # Copy application files
    WORKDIR /var/www
    COPY . .
    
    # Install composer dependencies (in case you want to run composer scripts)
    RUN composer install --optimize-autoloader --no-dev
    
    # Generate key (optional: you can also do this on your local)
    # RUN php artisan key:generate
    
    # Set permissions
    RUN chown -R www-data:www-data /var/www \
        && chmod -R 755 /var/www/storage
    
    # Copy nginx config
    COPY docker/nginx.conf /etc/nginx/nginx.conf
    
    # Expose port 80
    EXPOSE 80
    
    # Start php-fpm and nginx
    CMD ["/bin/sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
    