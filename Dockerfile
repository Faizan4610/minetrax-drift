FROM php:8.2-cli

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
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------
# PHP extensions (FULL SET)
# ----------------------------
RUN docker-php-ext-configure gd --with-jpeg --with-webp \
    && docker-php-ext-install \
        zip \
        pdo \
        pdo_pgsql \
        exif \
        sockets \
        bcmath \
        intl \
        gd

# ----------------------------
# Composer
# ----------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ----------------------------
# App setup
# ----------------------------
WORKDIR /app
COPY . .

# ----------------------------
# Laravel permissions (important)
# ----------------------------
RUN chown -R www-data:www-data storage bootstrap/cache || true

# ----------------------------
# Install backend deps
# ----------------------------
RUN composer install --no-dev --optimize-autoloader

# ----------------------------
# Build frontend (Vite)
# ----------------------------
RUN npm install && npm run build

# ----------------------------
# Expose Render port
# ----------------------------
EXPOSE 10000

# ----------------------------
# Start app
# ----------------------------
CMD php artisan key:generate --force \
 && php artisan migrate --force \
 && php artisan serve --host=0.0.0.0 --port=10000
