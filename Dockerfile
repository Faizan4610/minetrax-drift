FROM php:8.3-fpm

# ----------------------------
# System dependencies
# ----------------------------
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libzip-dev \
    libpq-dev \
    libjpeg-dev \
    libpng-dev \
    libwebp-dev \
    libicu-dev \
    libonig-dev \
    libsodium-dev \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------
# PHP extensions (MineTrax required)
# ----------------------------
RUN docker-php-ext-configure gd --with-jpeg --with-webp \
    && docker-php-ext-install \
        pdo \
        pdo_pgsql \
        zip \
        exif \
        intl \
        bcmath \
        gd \
        sodium \
        sockets \
        ftp

# ----------------------------
# Composer
# ----------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ----------------------------
# App setup
# ----------------------------
WORKDIR /app
COPY . .

# Laravel writable dirs
RUN chown -R www-data:www-data storage bootstrap/cache || true

# ----------------------------
# Backend dependencies ONLY
# ----------------------------
RUN composer install --no-dev --optimize-autoloader

# ----------------------------
# Railway port
# ----------------------------
EXPOSE 8080

# ----------------------------
# Start MineTrax
# ----------------------------
CMD php artisan key:generate --force \
 && php artisan migrate --force \
 && php artisan serve --host=0.0.0.0 --port=${PORT:-8080}
