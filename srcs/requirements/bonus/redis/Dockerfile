FROM debian:bookworm
RUN apt-get update && apt-get install -y --no-install-recommends redis-server \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/redis && chown redis:redis /run/redis \
    && sed -i 's/^bind .*/bind 0.0.0.0/; s/^protected-mode yes/protected-mode no/; s|^logfile .*|logfile ""|' /etc/redis/redis.conf
EXPOSE 6379
CMD ["redis-server", "/etc/redis/redis.conf", "--daemonize", "no"]
