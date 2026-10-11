.PHONY: up down restart logs build init

-include .env
export

DOCKER_COMPOSE = podman-compose

up:
	$(DOCKER_COMPOSE) build
	$(DOCKER_COMPOSE) up -d

down:
	$(DOCKER_COMPOSE) down

restart:
	$(DOCKER_COMPOSE) restart

logs:
	$(DOCKER_COMPOSE) logs -f

build:
	$(DOCKER_COMPOSE) build --no-cache

# Первый запуск с получением SSL-сертификата
# Использование: make init DOMAIN=resume.example.com EMAIL=you@example.com
init:
	DOMAIN=$(DOMAIN) EMAIL=$(EMAIL) ./init-ssl.sh
