#!/bin/bash
set -e
FTP_PASSWORD="$(cat /run/secrets/ftp_password)"

# The FTP user shares the www-data UID/GID, so files uploaded over FTP and
# files written by WordPress (PHP-FPM) have the same owner and stay editable
# from both sides.
if ! id "$FTP_USER" >/dev/null 2>&1; then
    useradd --non-unique --uid "$(id -u www-data)" --gid www-data \
        --home-dir /var/www/html --no-create-home --shell /bin/bash "$FTP_USER"
fi
echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
echo "$FTP_USER" > /etc/vsftpd.userlist

exec vsftpd /etc/vsftpd.conf
