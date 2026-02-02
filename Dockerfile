FROM php:8.2-cli

# System deps
RUN apt-get update && apt-get install -y \
    git unzip curl libzip-dev nodejs npm \
    && docker-php-ext-install zip pdo pdo_mysql pdo_pgsql

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copy project
COPY . .

# Install PHP deps
RUN composer install --no-dev --optimize-autoloader

# Install Node deps & build assets
RUN npm install && npm run build

EXPOSE 10000

CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=10000
