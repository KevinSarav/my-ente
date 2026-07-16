#!/usr/bin/env bash
set -euo pipefail

DEPLOY_PATH="${DEPLOY_PATH:-$HOME/apps/my-ente}"
DEPLOY_BRANCH="${DEPLOY_BRANCH:-main}"

cd "$DEPLOY_PATH"

if [[ ! -d .git ]]; then
  echo "Missing git repository in $DEPLOY_PATH"
  echo "Clone your GitHub repo at this path first"
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "Git remote origin is not configured in $DEPLOY_PATH"
  exit 1
fi

# Make working tree match the latest commit on deployment branch.
git fetch --prune origin
git checkout "$DEPLOY_BRANCH"
git reset --hard "origin/$DEPLOY_BRANCH"

if [[ -f .env.sops ]]; then
  if ! command -v sops >/dev/null 2>&1; then
    echo "Found $DEPLOY_PATH/.env.sops but sops is not installed on server"
    exit 1
  fi

  tmp_env="$(mktemp)"
  trap 'rm -f "$tmp_env"' EXIT

  echo "Decrypting $DEPLOY_PATH/.env.sops to runtime .env"
  sops --decrypt --input-type dotenv --output-type dotenv .env.sops > "$tmp_env"
  install -m 600 "$tmp_env" .env
  rm -f "$tmp_env"
  trap - EXIT
fi

if [[ ! -f .env ]]; then
  echo "Missing $DEPLOY_PATH/.env on server"
  echo "Commit .env.sops (encrypted) or create .env manually on server"
  exit 1
fi

# Render museum config with current env before starting containers.
sh ./scripts/render-museum-config.sh museum.yaml museum.rendered.yaml

docker compose pull
if [[ -n "${MUSEUM_IMAGE_OVERRIDE:-}" ]]; then
  echo "Museum image override requested: pulling $MUSEUM_IMAGE_OVERRIDE"
  docker pull "$MUSEUM_IMAGE_OVERRIDE"
  docker tag "$MUSEUM_IMAGE_OVERRIDE" ghcr.io/ente/server:latest
  echo "Retagged as ghcr.io/ente/server:latest — compose will use this image."
fi
if [[ -n "${WEB_IMAGE_OVERRIDE:-}" ]]; then
  echo "Web image override requested: pulling $WEB_IMAGE_OVERRIDE"
  docker pull "$WEB_IMAGE_OVERRIDE"
  docker tag "$WEB_IMAGE_OVERRIDE" ghcr.io/ente/web:latest
  echo "Retagged as ghcr.io/ente/web:latest — compose will use this image."
fi
docker compose up -d --remove-orphans

# Keep rendered config ephemeral, similar to local Makefile behavior.
rm -f museum.rendered.yaml

docker image prune -f >/dev/null 2>&1 || true

echo "Ente deployment completed from branch $DEPLOY_BRANCH in $DEPLOY_PATH"
