SHELL := /bin/sh

.PHONY: render up down restart restart-all logs ps

render:
	./scripts/render-museum-config.sh

up: render
	docker compose up -d; \
	ret=$$?; \
	rm -f museum.rendered.yaml; \
	exit $$ret

down:
	docker compose down

restart: render
	docker compose up -d --force-recreate museum

restart-all: render
	docker compose up -d --force-recreate museum web minio socat; \
	ret=$$?; \
	rm -f museum.rendered.yaml; \
	exit $$ret

logs:
	docker compose logs --tail=120 -f museum

ps:
	docker compose ps
