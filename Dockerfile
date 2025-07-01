FROM php:8.1-cli

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git unzip zip cron \
    libpng-dev libonig-dev libxml2-dev libzip-dev \
    libc-client-dev libkrb5-dev \
    libjpeg-dev libfreetype6-dev libxpm-dev libwebp-dev \
    libssl-dev libcurl4-openssl-dev pkg-config libicu-dev \
    autoconf g++ make curl nano libtool

# ✅ Configure and install extensions

# IMAP requires special configure before install
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap

# GD with JPEG + WebP support
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install gd

# Other core PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath zip json xml

# Install Composer from official Composer image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy project files
COPY . /var/www/html

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Add entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose Laravel's internal dev port
EXPOSE 10000

# Start Laravel server via entrypoint
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]
