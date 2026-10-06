#!/bin/bash
set -e
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
cd /var/www/html
until mariadb-admin ping -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
    echo "waiting for mariadb..."; sleep 2
done
if [ ! -f wp-config.php ]; then
    wp core download --allow-root
    wp config create --allow-root --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --dbhost=mariadb
    wp core install --allow-root --url="https://$DOMAIN_NAME" --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" --skip-email
    wp user create "$WP_USER" "$WP_USER_EMAIL" --allow-root \
        --user_pass="$WP_USER_PASSWORD" --role=author
fi
if [ "${WP_REDIS_ENABLED:-0}" = "1" ]; then
    attempts=0
    until getent hosts redis >/dev/null && (echo > /dev/tcp/redis/6379) 2>/dev/null; do
        attempts=$((attempts + 1))
        if [ "$attempts" -ge 30 ]; then
            echo "Redis did not become ready" >&2
            exit 1
        fi
        echo "waiting for redis..."; sleep 2
    done
    if ! wp plugin is-installed redis-cache --allow-root; then
        wp plugin install redis-cache --activate --allow-root
    fi
    wp config set WP_REDIS_HOST redis --allow-root
    wp config set WP_REDIS_PORT 6379 --raw --allow-root
    wp redis enable --allow-root
fi
chown -R www-data:www-data /var/www/html
exec php-fpm8.2 -F
