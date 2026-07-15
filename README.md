<div align="center">

<img src=".github/assets/ente-rocketship.png" width="400"/>

Fully open source end-to-end encrypted photos, authenticators and more.

</div>

# Ente

Ente is a service that provides a fully open source, end-to-end encrypted platform for you to store your data in the cloud without needing to trust the service provider.

Automatically deployed to my Ubuntu Server with Docker Compose via GitHub Actions whenever changes are pushed to main

Learn more at [ente.com](https://ente.com).

## Docker Deploy

1. Copy `.env.example` to `.env` and fill in production values.
2. Review self-hosting setup and configuration docs: https://ente.com/help/self-hosting.
3. Start or update the stack with:

```bash
make up
```

Requires `make` to be installed.

`make up` renders `museum.rendered.yaml` from `.env`, runs `docker compose up -d`, then removes the rendered file.

4. If you run Docker Compose manually, render first:

```bash
./scripts/render-museum-config.sh
docker compose up -d
```

5. To update published images before recreating containers:

```bash
docker compose pull
make up
```

## GitHub Actions Deployment

Workflow: `.github/workflows/deploy-ente.yml`

Triggers:
- Push to `main`
- Manual run (`workflow_dispatch`)

Required GitHub secrets (repo-level or Environment `production`):
- `DEPLOY_USER`
- `DEPLOY_HOST`
- `DEPLOY_PATH`
- `DEPLOY_SSH_PRIVATE_KEY`

Optional GitHub secret:
- `DEPLOY_PORT` (defaults to `22`)

Server requirements for encrypted env deploys:
- `sops` must be installed on the server.
- The server must have an Age private key matching one of the public recipients listed in `.sops.yaml`.

## Encrypt `.env` to `.env.sops` (Manual)

Use SOPS locally whenever `.env` changes:

```bash
sops --encrypt --input-type dotenv --output-type dotenv .env > .env.sops
chmod 600 .env.sops
```

If you rotate or add Age keys, update recipients in `.sops.yaml` under `creation_rules[].age`, then re-encrypt:

```bash
sops updatekeys .env.sops
```
