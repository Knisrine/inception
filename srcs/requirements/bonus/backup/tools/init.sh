#!/bin/bash
set -e
printf 'MYSQL_USER=%s\nMYSQL_DATABASE=%s\n' "$MYSQL_USER" "$MYSQL_DATABASE" > /etc/backup.env
export MYSQL_PWD="$(cat /run/secrets/db_password)"
until mariadb-admin ping -h mariadb -u"$MYSQL_USER" --silent; do
    echo "waiting for mariadb..."; sleep 2
done
/usr/local/bin/backup.sh || true
exec cron -f
