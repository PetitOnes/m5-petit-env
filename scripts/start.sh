#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -f "$ROOT_DIR/.env" ]; then
  echo ".env が見つかりません。.env.example をコピーして作成してください: cp .env.example .env" >&2
  exit 1
fi

"$ROOT_DIR/scripts/sync-repos.sh"
docker compose --env-file "$ROOT_DIR/.env" up --build
