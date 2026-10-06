COMPOSE = docker compose -f srcs/docker-compose.yml
BONUS_COMPOSE = $(COMPOSE) -f srcs/docker-compose.bonus.yml
DATA = $(shell sed -n 's/^DATA_PATH=//p' srcs/.env)

all: up

up:
	@test -f srcs/.env || (echo "Missing srcs/.env" >&2; exit 1)
	@for secret in db_password db_root_password wp_admin_password wp_user_password; do \
		test -s "secrets/$$secret.txt" || (echo "Missing or empty secrets/$$secret.txt" >&2; exit 1); \
	done
	mkdir -p $(DATA)/mariadb $(DATA)/wordpress $(DATA)/backups
	$(COMPOSE) up -d --build

bonus:
	@test -f srcs/.env || (echo "Missing srcs/.env" >&2; exit 1)
	@for secret in db_password db_root_password wp_admin_password wp_user_password; do \
		test -s "secrets/$$secret.txt" || (echo "Missing or empty secrets/$$secret.txt" >&2; exit 1); \
	done
	mkdir -p $(DATA)/mariadb $(DATA)/wordpress $(DATA)/backups
	$(BONUS_COMPOSE) up -d --build

down:
	$(COMPOSE) down --remove-orphans

bonus-down:
	$(BONUS_COMPOSE) down --remove-orphans

clean:
	$(COMPOSE) down --remove-orphans --rmi all -v

bonus-clean:
	$(BONUS_COMPOSE) down --remove-orphans --rmi all -v

fclean: clean
	sudo rm -rf $(DATA)/mariadb $(DATA)/wordpress $(DATA)/backups

re: fclean all

.PHONY: all up bonus down bonus-down clean bonus-clean fclean re
