#!/bin/bash

set -e

DB_HOST=mariadb
DB_NAME=$MYSQL_DATABASE
DB_USER=$MYSQL_USER
DB_PASSWORD=$(cat /run/secrets/db_password)

source /run/secrets/credentials

mkdir -p /var/www/html /run/php

# Copy WordPress files
if [ ! -f "/var/www/html/wp-load.php" ]; then
    cp -a /usr/src/wordpress/. /var/www/html/
fi

# Wait for MariaDB
counter=0

while ! (exec 3<>/dev/tcp/$DB_HOST/3306) 2>/dev/null && ((counter < 20)); do
    echo "Waiting for MariaDB setup to finish..."
    sleep 1
    counter=$((counter + 1))
done

if ((counter >= 20)); then
    echo "MariaDB never became reachable, giving up" >&2
    exit 1
fi

# Create WordPress configuration
if [ ! -f "/var/www/html/wp-config.php" ]; then
    wp config create \
        --path=/var/www/html \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$DB_HOST" \
        --allow-root
fi

# Install WordPress
if ! wp core is-installed --path=/var/www/html --allow-root; then
    wp core install \
        --path=/var/www/html \
        --url=https://mbouchri.42.fr \
        --title="Inception" \
        --admin_user=mbouchri \
        --admin_password="$ADMIN_PASSWORD" \
        --admin_email=bouchritmeryeme@gmail.com \
        --skip-email \
        --allow-root
fi

# Create regular WordPress user
if ! wp user get visitor --path=/var/www/html --allow-root >/dev/null 2>&1; then
    wp user create visitor visitor@example.com \
        --path=/var/www/html \
        --user_pass="$USER_PASSWORD" \
        --role=subscriber \
        --allow-root
fi

# Set permissions
chown -R www-data:www-data /var/www/html

# Start PHP-FPM
exec "$@"
