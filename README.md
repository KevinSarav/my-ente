# my-ente

Local self-hosted Ente stack using Docker Compose with a generated `museum.rendered.yaml`.

This repository is based on Ente's official self-hosting flow and images, with one important local customization:
we render `museum.yaml` from `.env` before starting containers.

## Why `make up` is needed

`museum.yaml` contains placeholder variables like `${MUSEUM_DB_PORT}`.
Docker Compose only interpolates variables in `compose.yaml`, not in mounted config files.

If `museum.yaml` is mounted directly, placeholders remain literal and `museum` fails to boot (for example, base64 and type parse errors).

`make up` solves this by:
1. Loading `.env`
2. Rendering `museum.yaml` to `museum.rendered.yaml`
3. Failing fast if a required variable is missing or unresolved
4. Running `docker compose up -d`

## Commands

- `make up`: render config and start/update stack
- `make down`: stop stack
- `make restart`: re-render and force recreate `museum`
- `make logs`: follow `museum` logs
- `make ps`: show container status
- `make render`: only render `museum.rendered.yaml`

## File layout

- `compose.yaml`: service definitions
- `.env`: runtime values for placeholders
- `museum.yaml`: template config with placeholders
- `museum.rendered.yaml`: generated config (gitignored)
- `scripts/render-museum-config.sh`: host-side renderer

## Adding or changing variables

1. Add/update the variable in `.env`
2. Reference it in `museum.yaml` as `${YOUR_VAR}`
3. Run `make up`

## About Ente

Ente is an open-source end-to-end encrypted platform powering apps like Photos, Auth, and Locker.

For authoritative product and self-hosting docs, see:
- Official repository: https://github.com/ente-io/ente
- Official README: https://github.com/ente-io/ente/blob/main/README.md
- Self-hosting quickstart: https://ente.com/help/self-hosting/

## GitHub Actions deployment

This repo includes GitHub Actions deployment at `.github/workflows/deploy-ente.yml`.

Behavior:
- Push to `main` triggers deployment.
- Workflow always syncs remote `.env` from secret `ENTE_ENV_FILE`.
- Server updates to latest `main` and runs Docker Compose.

Required GitHub Actions environment secrets (environment: `production`):
- `DEPLOY_HOST`
- `DEPLOY_PORT` (optional, defaults to `22`)
- `DEPLOY_USER`
- `DEPLOY_PATH` (path to this repo on server)
- `DEPLOY_SSH_PRIVATE_KEY`
- `ENTE_ENV_FILE` (full multiline content of local `.env`)

Sync local `.env` into `ENTE_ENV_FILE`:

```bash
./scripts/sync-ente-env-secret.sh
```

Optional arguments:

```bash
./scripts/sync-ente-env-secret.sh <environment-name> <secret-name> <env-file-path>
```
