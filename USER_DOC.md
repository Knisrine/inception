# User Documentation

## Services

- NGINX provides the HTTPS entrypoint on port 443.
- WordPress serves the main website through PHP-FPM.
- MariaDB stores the WordPress database.
- Redis provides the WordPress object cache.
- Adminer provides a browser database administration panel.
- The static container serves the project showcase site.
- The backup container creates compressed MariaDB backups every 30 minutes.

The first three services are mandatory. Redis, Adminer, the static site, and backups are bonus services started with `make bonus`.

## Start and stop

From the repository root:

```sh
make
make bonus
make down
make bonus-down
```

`make clean` removes containers, images, and Docker volumes. `make fclean` also removes the persistent data under `/home/nikhtib/data`.

## Access

- WordPress: `https://nikhtib.42.fr/`
- Adminer: `https://nikhtib.42.fr/adminer/`
- Static site: `https://nikhtib.42.fr/site/`

Because the project uses a self-signed certificate, the browser may show a certificate warning during local use.

## Credentials and data

Passwords are stored locally in the ignored `secrets/` directory. They are mounted into containers as Docker secrets and are not stored in the Git repository. The WordPress and MariaDB data are stored under `/home/nikhtib/data`.

## Check the stack

```sh
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs --tail=100 nginx
docker compose -f srcs/docker-compose.yml logs --tail=100 wordpress
docker compose -f srcs/docker-compose.yml exec mariadb mariadb-admin ping
```

All expected containers should be running, and the MariaDB ping should report that the server is alive.
