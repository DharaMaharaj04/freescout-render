FROM php:8.1-cli

# Install dependencies
RUN apt-get update && apt-get install -y git unzip libpng-dev libonig-dev libxml2-dev zip unzip cron

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy app files
COPY . /var/www/html

# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Run migrations and scheduler (in entrypoint)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 10000

# Start Laravel built-in web server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]
