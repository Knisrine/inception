FROM debian:bookworm
RUN apt-get update && apt-get install -y --no-install-recommends cron mariadb-client gzip \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /backups
COPY tools/backup.sh /usr/local/bin/backup.sh
COPY tools/init.sh /usr/local/bin/init.sh
COPY conf/backup.cron /etc/cron.d/backup
RUN chmod +x /usr/local/bin/backup.sh /usr/local/bin/init.sh \
    && chmod 0644 /etc/cron.d/backup
ENTRYPOINT ["/usr/local/bin/init.sh"]
