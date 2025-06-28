FROM php:8.1-fpm

RUN apt-get update && apt-get install -y git unzip libpng-dev libonig-dev libxml2-dev zip unzip cron

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . /var/www/html



RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
