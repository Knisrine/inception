*This project has been created as part of the 42 curriculum by nikhtib.*

# Inception

## Description

Inception is a Docker Compose infrastructure that runs a WordPress website behind an NGINX TLS reverse proxy. The stack is built from custom Debian-based Dockerfiles and uses separate containers for NGINX, WordPress with PHP-FPM, MariaDB, Redis, Adminer, a static website, and scheduled database backups.

The main design choices are:

- NGINX is the only published entrypoint and exposes HTTPS on port 443.
- WordPress and MariaDB run in separate containers and communicate over the `inception` Docker network.
- Database and WordPress files persist in named Docker volumes backed by `/home/nikhtib/data`.
- Passwords are provided through Docker secrets; non-confidential settings are stored in `srcs/.env`.

### Virtual machines and Docker

A virtual machine runs a complete guest operating system with its own kernel and usually requires more resources. Docker containers share the host kernel, start faster, and isolate application processes while keeping services lightweight. This project uses a VM as required by the subject and Docker containers for the application services.

### Secrets and environment variables

Environment variables are useful for non-confidential configuration such as the domain, database name, and WordPress title. Passwords should not be placed in `.env` or image layers, so this project supplies them through Docker secrets mounted under `/run/secrets`.

### Docker network and host network

The user-defined `inception` bridge network gives containers private service-name DNS and controlled communication. Host networking would remove this isolation and expose services directly on the host network, so it is not used.

### Docker volumes and bind mounts

A named Docker volume is managed by Docker and can persist independently from a container. A bind mount directly exposes a chosen host directory. The Compose volume declarations use named volume objects with local-driver options so the required persistent data is stored under `/home/nikhtib/data`.

## Instructions

### Prerequisites

- A Linux virtual machine with Docker Engine and the Docker Compose plugin.
- The domain `nikhtib.42.fr` mapped to the VM IP address in DNS or `/etc/hosts`.
- Local secret files under `secrets/`:
  - `db_password.txt`
  - `db_root_password.txt`
  - `wp_admin_password.txt`
  - `wp_user_password.txt`

Create the data directories and start the stack with:

```sh
make
```

The mandatory stack uses `srcs/docker-compose.yml` and contains only NGINX, WordPress, and MariaDB. Start the optional services with `make bonus`, which adds `srcs/docker-compose.bonus.yml` for Redis, Adminer, the static site, and backups. Stop the mandatory stack with `make down` or the complete bonus stack with `make bonus-down`. Remove containers, images, and volumes with `make clean` or `make bonus-clean`. Remove all project data as well with `make fclean`. Rebuild the mandatory stack with `make re`.

The WordPress site is available at `https://nikhtib.42.fr/`. Adminer is available at `https://nikhtib.42.fr/adminer/`, and the static site is available at `https://nikhtib.42.fr/site/`.

## Resources

- Docker documentation: https://docs.docker.com/
- Docker Compose file reference: https://docs.docker.com/reference/compose-file/
- NGINX documentation: https://nginx.org/en/docs/
- WordPress developer resources: https://developer.wordpress.org/
- WP-CLI documentation: https://developer.wordpress.org/cli/commands/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/
- Redis documentation: https://redis.io/docs/

AI was used to help review the project requirements, compare the implementation with the subject, identify configuration risks, and check shell and Compose-related setup. All generated suggestions were reviewed against the subject and the local project files.
