#!/usr/bin/env bash

# Wait until MySQL is available
while ! nc -z "$DB_HOST" "$DB_PORT"; do
  echo "⏳ Waiting for MySQL at $DB_HOST:$DB_PORT..."
  sleep 2
done

# Run database migrations
php artisan migrate --force

# Start scheduler in background
php artisan schedule:work &

# ✅ Start Laravel's built-in web server (required for Render)
exec php artisan serve --host=0.0.0.0 --port=10000
