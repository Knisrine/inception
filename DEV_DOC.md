# Developer Documentation

## Prerequisites

Use a Linux virtual machine with Docker Engine and the Docker Compose plugin. Configure `nikhtib.42.fr` to resolve to the VM address, or add the mapping to `/etc/hosts`.

## Configuration

Non-secret settings are in `srcs/.env`. Create the ignored `secrets/` directory at the repository root and add:

```text
secrets/db_password.txt
secrets/db_root_password.txt
secrets/wp_admin_password.txt
secrets/wp_user_password.txt
```

Each file should contain only its password. Do not commit these files.

## Build and launch

From the repository root:

```sh
make
make bonus
```

`make` builds the mandatory stack from `srcs/docker-compose.yml`. `make bonus` layers `srcs/docker-compose.bonus.yml` on top and adds Redis, Adminer, the static site, and backups. Both targets create the persistent data directories before launching Compose.

Useful lifecycle commands:

```sh
make up
make bonus
make down
make bonus-down
make clean
make bonus-clean
make fclean
make re
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f SERVICE_NAME
```

## Containers and volumes

The Compose project defines the `inception` network and one container per service. The required persistent volumes are `mariadb_data` and `wordpress_data`; the backup service uses `backup_data`. Their host data is configured under `/home/nikhtib/data` through `srcs/.env`.

To inspect volumes:

```sh
docker volume ls
docker volume inspect mariadb_data
docker volume inspect wordpress_data
docker volume inspect backup_data
```

To remove volumes, use `make clean`. To remove their host data too, use `make fclean`.
