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

if [[ ! -f .env ]]; then
  echo "Missing $DEPLOY_PATH/.env on server"
  echo "Set ENTE_ENV_FILE in GitHub Actions environment secrets"
  exit 1
fi

# Render museum config with current env before starting containers.
sh ./scripts/render-museum-config.sh museum.yaml museum.rendered.yaml

docker compose pull
docker compose up -d --remove-orphans

# Keep rendered config ephemeral, similar to local Makefile behavior.
rm -f museum.rendered.yaml

docker image prune -f >/dev/null 2>&1 || true

echo "Ente deployment completed from branch $DEPLOY_BRANCH in $DEPLOY_PATH"
