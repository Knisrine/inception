# Inception Project Explanation

## 1. Project Goal

This project builds a small WordPress infrastructure with Docker Compose inside a virtual machine. Each service has its own custom Dockerfile and dedicated container. The services communicate through a user-defined Docker bridge network, while NGINX is the only service published to the host.

The repository contains a mandatory stack and an optional bonus overlay. Keeping them in separate Compose files makes it possible to run and evaluate the mandatory part independently.

## 2. Repository Structure

```text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── explanation_project.md
├── secrets/                         # local only, ignored by Git
└── srcs/
    ├── .env                         # non-secret configuration
    ├── docker-compose.yml           # mandatory stack
    ├── docker-compose.bonus.yml     # bonus overlay
    └── requirements/
        ├── mariadb/
        ├── nginx/
        ├── wordpress/
        └── bonus/
            ├── adminer/
            ├── backup/
            ├── redis/
            └── static/
```

## 3. Mandatory and Bonus Architecture

The mandatory Compose file contains only the three required services:

- `mariadb`: the WordPress database
- `wordpress`: WordPress with PHP-FPM, without NGINX
- `nginx`: the TLS entrypoint and reverse proxy

The bonus file is an overlay. It adds:

- `redis`: WordPress object cache
- `adminer`: database administration interface
- `static`: a non-PHP static website
- `backup`: periodic compressed MariaDB backups

The commands are:

```sh
make                 # mandatory services only
make bonus           # mandatory services plus bonus services
make down            # stop the mandatory Compose project
make bonus-down      # stop the complete bonus project
```

The mandatory stack does not depend on Redis, Adminer, the static site, or backups. Redis configuration in the WordPress entrypoint is enabled only when the bonus overlay sets `WP_REDIS_ENABLED=1`.

## 4. Why Debian Was Chosen

The images use Debian Bookworm rather than Alpine. Alpine images are smaller, but Alpine uses musl libc and can require additional compatibility work for PHP extensions, PHP-FPM, MariaDB initialization, and third-party tools such as WP-CLI.

Debian provides a broader and more familiar package ecosystem. The current stack has been built and tested successfully with Debian, PHP-FPM, MariaDB, NGINX, Redis, WP-CLI, Adminer, and cron. The base images are explicitly Debian-based and do not use the `latest` tag.

The subject permits either Alpine or Debian, provided the selected release is the required stable version for the evaluation period. The project should be checked against the subject version requirement before the final defense.

## 5. Mandatory Services

### MariaDB

MariaDB runs alone in its container. Its initialization script reads the database and root passwords from Docker secrets mounted under `/run/secrets`. On first initialization it creates the WordPress database and application user, then starts MariaDB as the container's main process.

MariaDB is not published to the host. WordPress reaches it through the Docker network using the service name `mariadb`.

### WordPress and PHP-FPM

The WordPress container installs PHP-FPM and the required PHP extensions. It does not install or run NGINX. The entrypoint waits for MariaDB, downloads and installs WordPress on the first run, creates the administrator and second WordPress user, and then executes PHP-FPM in the foreground.

The administrator username is configured as `nikhtib`, which does not contain `admin` or `administrator`.

Redis setup is optional and only runs when the bonus overlay sets `WP_REDIS_ENABLED=1`. When enabled, the entrypoint waits for Redis DNS and TCP readiness before enabling the object-cache plugin.

### NGINX

NGINX is the only published service. It listens on port 443 with a self-signed certificate generated at startup. The configuration allows TLS 1.2 and TLS 1.3 only.

NGINX forwards PHP requests to `wordpress:9000`. In bonus mode it also routes `/adminer/` to Adminer and `/site/` to the static website. Port 80 is not published on the host.

## 6. Storage

The project defines named Docker volumes for persistent storage:

- `mariadb_data` stores the database under `/home/nikhtib/data/mariadb`
- `wordpress_data` stores WordPress files under `/home/nikhtib/data/wordpress`
- `backup_data` stores compressed backups under `/home/nikhtib/data/backups`

The first two volumes are used by the mandatory stack. The backup volume belongs to the bonus overlay. The volumes remain Docker volume objects while the local driver options place their data under the required host directory.

## 7. Network and Security Choices

All services use the `inception` bridge network. Service-name DNS allows containers to connect using names such as `mariadb`, `wordpress`, and `redis`. Host networking and legacy `links` are not used.

Only NGINX publishes a host port:

```text
443:443
```

Database, PHP-FPM, Redis, Adminer, and the internal static NGINX port remain private to the Docker network.

Non-secret configuration is stored in `srcs/.env`. Passwords are stored in local files under `secrets/` and mounted as Docker secrets. The secrets directory is ignored by Git and must never be committed.

## 8. Bonus Services

### Redis

Redis provides WordPress object caching. It is private to the Docker network and is not published to the host.

### Adminer

Adminer provides a browser-based database administration panel at:

```text
https://nikhtib.42.fr/adminer/
```

### Static Website

The static service runs a separate NGINX container and serves HTML/CSS content without PHP. It is available through the NGINX route:

```text
https://nikhtib.42.fr/site/
```

### Backup

The backup service waits for MariaDB and periodically creates compressed SQL dumps. It keeps the most recent five backup files in the backup volume.

## 9. Verification

Build and inspect the mandatory stack:

```sh
make
docker compose -f srcs/docker-compose.yml ps
curl -kI https://nikhtib.42.fr/
```

Build and inspect the bonus stack:

```sh
make bonus
docker compose -f srcs/docker-compose.yml -f srcs/docker-compose.bonus.yml ps
curl -kI https://nikhtib.42.fr/adminer/
curl -kI https://nikhtib.42.fr/site/
```

Check Redis and persistence:

```sh
docker compose -f srcs/docker-compose.yml -f srcs/docker-compose.bonus.yml exec wordpress wp redis status --allow-root
docker volume ls
ls -la /home/nikhtib/data/mariadb
ls -la /home/nikhtib/data/wordpress
ls -la /home/nikhtib/data/backups
```

The mandatory stack should show three services. The bonus stack should show all seven services. HTTP port 80 should not be published; HTTPS port 443 is the only host entrypoint.
