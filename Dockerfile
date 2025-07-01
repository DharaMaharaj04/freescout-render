FROM php:8.1-cli

# Install system libraries
RUN apt-get update && apt-get install -y \
    git unzip zip cron nano curl autoconf build-essential \
    libpng-dev libjpeg-dev libwebp-dev libxpm-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev libc-client-dev libkrb5-dev \
    libssl-dev libcurl4-openssl-dev libicu-dev pkg-config libtool

# Configure and install IMAP
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install imap

# Configure and install GD with JPEG & WebP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install gd

# 🔽 Install PHP extensions (skip json - it's built-in!)
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install exif
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install zip
RUN docker-php-ext-install xml
RUN docker-php-ext-install intl

# Copy Composer from official image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy app files
COPY . /var/www/html

# Set folder permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose Laravel's dev server port
EXPOSE 10000

# Start Laravel dev server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]
