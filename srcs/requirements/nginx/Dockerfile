FROM debian:bookworm
RUN apt-get update && apt-get install -y --no-install-recommends nginx openssl \
    && rm -rf /var/lib/apt/lists/*
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf.template
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh && rm -f /etc/nginx/sites-enabled/default
EXPOSE 443
ENTRYPOINT ["/usr/local/bin/init.sh"]
