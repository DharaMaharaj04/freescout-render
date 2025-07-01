FROM php:8.1-cli

# Install base tools and required libraries
RUN apt-get update && apt-get install -y \
    git unzip zip cron nano curl autoconf build-essential \
    libpng-dev libjpeg-dev libwebp-dev libxpm-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev libc-client-dev libkrb5-dev \
    libssl-dev libcurl4-openssl-dev libicu-dev pkg-config libtool

# Install PHP extensions (configure where needed)
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install imap

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install gd

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath zip json xml intl

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy project files
COPY . /var/www/html

# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Add and configure entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Laravel dev server port
EXPOSE 10000

# Start the Laravel app
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]
