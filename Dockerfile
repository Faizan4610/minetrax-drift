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
    libsodium-dev \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------
# PHP extensions (FULL + REQUIRED)
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
        gd \
        sodium

# ----------------------------
# Composer
# ----------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ----------------------------
# App
# ----------------------------
WORKDIR /app
COPY . .

RUN chown -R www-data:www-data storage bootstrap/cache || true

# ----------------------------
# Install backend deps
# ----------------------------
RUN composer install --no-dev --optimize-autoloader

# ----------------------------
# Build frontend
# ----------------------------
RUN npm install && npm run build

EXPOSE 10000

# ----------------------------
# Start
# ----------------------------
CMD php artisan key:generate --force \
 && php artisan migrate --force \
 && php artisan serve --host=0.0.0.0 --port=10000
