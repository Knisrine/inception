FROM debian:bookworm
RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.2-fpm php8.2-mysql php8.2-curl php8.2-mbstring php8.2-xml \
    mariadb-client curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL -o /usr/local/bin/wp \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp
RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf \
    && mkdir -p /run/php /var/www/html
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh
WORKDIR /var/www/html
EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/init.sh"]
