FROM debian:bookworm
RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.2-fpm php8.2-mysql curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/www/adminer /run/php \
    && curl -fsSL -o /var/www/adminer/index.php \
       https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php \
    && test -s /var/www/adminer/index.php \
    && chown -R www-data:www-data /var/www/adminer \
    && sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf
EXPOSE 9000
CMD ["php-fpm8.2", "-F"]
