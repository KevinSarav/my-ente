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
