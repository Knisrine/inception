*This project has been created as part of the 42 curriculum by nikhtib.*

# Inception

## Description

Inception is a Docker Compose infrastructure that runs a WordPress website behind an NGINX TLS reverse proxy, inside a Debian virtual machine. Every service runs in its own container, built from our own Dockerfiles on `debian:bookworm`.

- **Mandatory stack** (`make`): NGINX, WordPress with PHP-FPM, and MariaDB.
- **Bonus stack** (`make bonus`): the mandatory stack plus Redis (WordPress object cache), Adminer (database web interface), a static showcase site, scheduled database backups, and an FTP server (vsftpd) pointing to the WordPress volume.

In the mandatory stack, NGINX is the only published entry point, on port 443, and accepts only TLSv1.2 and TLSv1.3. The bonus FTP server also publishes port 21 and the passive range 21100-21110.

## Instructions

### Prerequisites

- A Debian virtual machine with `make`, Docker Engine and the Docker Compose plugin.
- The domain `nikhtib.42.fr` mapped to the machine in `/etc/hosts`: `127.0.0.1 nikhtib.42.fr` (inside the VM).
- A data directory owned by your user: `mkdir -p /home/nikhtib/data`.
- `srcs/.env` (tracked, non-secret settings only) and the password files in `secrets/` (never committed). `secrets/ftp_password.txt` is needed only for `make bonus`.

Create the secrets once on a fresh clone:

```sh
mkdir -p secrets && chmod 700 secrets
for f in db_password db_root_password wp_admin_password wp_user_password ftp_password; do
  openssl rand -base64 18 | tr -d '/+=\n' > "secrets/$f.txt"
done
chmod 600 secrets/*.txt
```

### Run

| Command            | Effect                                                                                   |
|---------------------------------------------------------------------------------------------------------------|
| `make`                            | Build and start the mandatory stack (`srcs/docker-compose.yml`).          |
| `make bonus`                      | Build and start everything, adding `srcs/docker-compose.bonus.yml`.       |
| `make down` / `make bonus-down`   | Stop the mandatory / complete stack (data is kept).                       |
| `make clean` / `make bonus-clean` | Same, and also remove images and Docker volumes.                          |
| `make fclean`                     | `clean`, plus delete the data under `/home/nikhtib/data`.                 |
| `make re`                         | `fclean`, then `make`.                                                    |

The first start takes a few minutes while WordPress installs itself.

### Access

The WordPress site is available at `https://nikhtib.42.fr/`. After `make bonus`, Adminer is available at `https://nikhtib.42.fr/adminer/` and the static site at `https://nikhtib.42.fr/site/`. The certificate is self-signed, so the browser shows a warning that must be accepted. The WordPress administrator is `nikhtib`, with the password from `secrets/wp_admin_password.txt`.

### FTP (bonus)

After `make bonus`, an FTP server gives access to the WordPress files (`/home/nikhtib/data/wordpress`). Log in as `ftpuser` (`FTP_USER` in `srcs/.env`), with the password from `secrets/ftp_password.txt`:

```sh
curl --user ftpuser:"$(cat secrets/ftp_password.txt)" ftp://nikhtib.42.fr/                  # list the site root
curl --user ftpuser:"$(cat secrets/ftp_password.txt)" -T file.txt ftp://nikhtib.42.fr/       # upload a file
curl --user ftpuser:"$(cat secrets/ftp_password.txt)" ftp://nikhtib.42.fr/wp-config.php -o - # download a file
```

Any FTP client (FileZilla, `lftp`, `ftp`) works as well, in passive mode on port 21. Anonymous login is disabled, and the user is locked (chroot) inside the WordPress directory.

## Project description

### Use of Docker and sources included

Docker runs each service as an isolated container, and Docker Compose describes the services, network, volumes and secrets in one place. The sources are:

- `Makefile`: builds and starts the stacks.
- `srcs/docker-compose.yml`: NGINX, WordPress, MariaDB, the `inception` network, the two data volumes and the secrets.
- `srcs/docker-compose.bonus.yml`: Redis, Adminer, the static site, the backup service and the FTP server.
- `srcs/requirements/<service>/`: one Dockerfile per service, with its configuration in `conf/` and its startup script in `tools/`.
- `srcs/.env`: non-secret settings (domain, database name, user names, emails, data path, FTP user).
- `secrets/`: password files, ignored by git and created locally.

### Main design choices

- One process per container, started with `exec` so it runs as PID 1. No keep-alive hacks are used; the wait loops in the startup scripts end when the dependency answers.
- WordPress runs PHP-FPM only, with no web server inside. NGINX forwards PHP requests to it over FastCGI on port 9000.
- Startup scripts are idempotent: existing databases, WordPress files and certificates are never reinitialized.
- NGINX resolves the WordPress, Adminer and static-site hosts per request, so the mandatory stack starts without the bonus containers and survives containers being recreated.
- All containers restart automatically (`restart: always`).
- Bonus service of our choice: scheduled MariaDB backups. All site data lives in two folders, so a dump every 30 minutes (the last five kept) protects it from a bad rebuild or a corrupted volume, and it can be restored with one command.
- FTP server: vsftpd runs in the foreground as PID 1 and mounts the same `wordpress_data` volume as WordPress, read-write, at `/var/www/html`. The FTP user is created at startup with the UID and GID of `www-data`, so files uploaded over FTP and files written by WordPress have the same owner and stay editable from both sides. Its password comes from the `ftp_password` Docker secret. Passive mode uses the fixed port range 21100-21110, which is published alongside port 21.

### Virtual machines vs Docker

A virtual machine runs a complete guest operating system with its own kernel, so it is heavier and slower to start. Docker containers share the host kernel, start in seconds and isolate application processes. This project uses a VM, as the subject requires, and Docker containers for the services running inside it.

### Secrets vs environment variables

Environment variables are visible through `docker inspect` and in the process environment, so they suit non-confidential settings such as the domain and database name. Docker secrets are mounted as files under `/run/secrets/` and are readable only by the processes that need them. Passwords therefore live in `secrets/`, while `srcs/.env` holds only non-secret values.

### Docker network vs host network

A user-defined bridge network (`inception`) gives each container its own network stack, private addresses and DNS by service name. Host networking removes that isolation and exposes every port of a service on the host, so it is not used (and is forbidden by the subject). Only NGINX publishes a port.

### Docker volumes vs bind mounts

A named volume is managed by Docker and lives independently of any container, while a bind mount maps a chosen host path directly. The subject requires named volumes whose data lives under `/home/<login>/data`, so the Compose file declares named volumes (`mariadb_data`, `wordpress_data`, `backup_data`) with the local driver and bind options pointing at `/home/nikhtib/data`. They appear in `docker volume ls`, and the data survives `make down` and `make clean`.

## Resources

- Docker documentation: https://docs.docker.com/
- Docker Compose file reference: https://docs.docker.com/reference/compose-file/
- NGINX documentation: https://nginx.org/en/docs/
- WordPress developer resources: https://developer.wordpress.org/
- WP-CLI documentation: https://developer.wordpress.org/cli/commands/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/
- Redis documentation: https://redis.io/docs/

### Use of AI

AI was used to help review the project requirements, identify configuration risks, and check shell and Compose-related setup. All generated suggestions were reviewed against the subject and the local project files.
