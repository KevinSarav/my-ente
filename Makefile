SHELL := /bin/sh

.PHONY: render up down restart logs ps

render:
	./scripts/render-museum-config.sh

up: render
	docker compose up -d

down:
	docker compose down

restart: render
	docker compose up -d --force-recreate museum

logs:
	docker compose logs --tail=120 -f museum

ps:
	docker compose ps
