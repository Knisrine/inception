# User Documentation

## Services

- NGINX provides the HTTPS entrypoint on port 443.
- WordPress serves the main website through PHP-FPM.
- MariaDB stores the WordPress database.
- Redis provides the WordPress object cache.
- Adminer provides a browser database administration panel.
- The static container serves the project showcase site.
- The backup container creates compressed MariaDB backups every 30 minutes.
- The FTP container (vsftpd) gives FTP access to the WordPress files.

The first three services are mandatory. Redis, Adminer, the static site, backups, and FTP are bonus services started with `make bonus`.

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
- FTP: `ftp://nikhtib.42.fr` (port 21), user `ftpuser`, password in `secrets/ftp_password.txt`

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

## Administration panel

The WordPress administration panel is at `https://nikhtib.42.fr/wp-admin`.

| Account | Role | Password file |
|---|---|---|
| `nikhtib` | Administrator | `secrets/wp_admin_password.txt` |
| `editor1` | Author | `secrets/wp_user_password.txt` |

Show a password with `cat secrets/wp_admin_password.txt`. The certificate is self-signed, so the browser warns once; accept it to continue. These files are never committed, so keep a private copy.

## Check that the services are running

```sh
docker ps --format '{{.Names}}: {{.Status}}'
curl -kI https://nikhtib.42.fr
```

All containers must show `Up` and the `curl` must answer `HTTP/1.1 200 OK`. After `make bonus` there are eight containers, and these also answer `200`:

```sh
curl -kI https://nikhtib.42.fr/adminer/
curl -ks https://nikhtib.42.fr/site/ | head -3
```

The FTP server must list the WordPress files:

```sh
curl --user ftpuser:"$(cat secrets/ftp_password.txt)" ftp://nikhtib.42.fr/
```

Wait about a minute after starting: WordPress installs itself on the first start, and a 403 or 502 during that time is normal. If a container is not `Up`, read its logs with `docker logs <name>`.
