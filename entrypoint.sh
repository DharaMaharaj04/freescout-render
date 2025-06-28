#!/usr/bin/env bash

while ! nc -z "$DB_HOST" "$DB_PORT"; do
  echo "⏳ Waiting for MySQL..."
  sleep 2
done

php artisan migrate --force
php artisan schedule:work &

php-fpm
