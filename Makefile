COMPOSE = docker compose --env-file srcs/.env -f srcs/docker-compose.yml

DATA_DIR = /home/mbouchri/data

all: build up

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean: down
	$(COMPOSE) down --rmi local --remove-orphans

fclean: clean

re: clean all

.PHONY: all build up down clean fclean re
