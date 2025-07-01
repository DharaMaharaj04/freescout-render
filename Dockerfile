FROM php:8.1-cli

# Install system dependencies for required PHP extensions
RUN apt-get update && apt-get install -y \
    git unzip zip cron \
    libpng-dev libonig-dev libxml2-dev libzip-dev \
    libc-client-dev libkrb5-dev \
    libjpeg-dev libfreetype6-dev libxpm-dev libwebp-dev \
    libssl-dev libcurl4-openssl-dev pkg-config libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd json xml zip imap

# Install Composer (from official Composer image)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application source code
COPY . /var/www/html

# Set correct permissions for Laravel storage & cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Add entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose Laravel's internal port (used by built-in web server)
EXPOSE 10000

# Start the Laravel development server (handled via entrypoint)
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]
