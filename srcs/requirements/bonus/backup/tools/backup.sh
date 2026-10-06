#!/bin/bash
set -e
. /etc/backup.env
export MYSQL_PWD="$(cat /run/secrets/db_password)"
file="/backups/${MYSQL_DATABASE}-$(date +%Y%m%d-%H%M%S).sql.gz"
mariadb-dump -h mariadb -u"$MYSQL_USER" --single-transaction "$MYSQL_DATABASE" | gzip > "$file"
ls -1t /backups/*.sql.gz | tail -n +6 | xargs -r rm --
echo "backup written: $file"
