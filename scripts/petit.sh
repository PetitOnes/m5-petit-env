#!/usr/bin/env bash
# ぷちDocker環境の日常操作コマンド。
#
# Usage:
#   ./scripts/petit.sh update   コンポーネントリポジトリを最新化してビルド・再起動
#   ./scripts/petit.sh logs     ログを表示(-f でフォロー)
#   ./scripts/petit.sh status   コンテナの状態を表示
#   ./scripts/petit.sh stop     コンテナを停止
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

cmd="${1:-}"
if [ $# -gt 0 ]; then shift; fi

case "$cmd" in
  update)
    echo "== コンポーネントリポジトリを更新 =="
    ./scripts/sync-repos.sh
    echo "== イメージを再ビルドして再起動 =="
    docker compose --env-file .env up --build -d
    ;;
  logs)
    docker compose --env-file .env logs "$@"
    ;;
  status)
    docker compose --env-file .env ps
    ;;
  stop)
    docker compose --env-file .env down
    ;;
  *)
    cat <<'USAGE'
使い方: ./scripts/petit.sh <command>

  update   コンポーネントリポジトリを最新化してビルド・再起動
  logs     ログを表示(-f でフォロー)
  status   コンテナの状態を表示
  stop     コンテナを停止

例:
  ./scripts/petit.sh update
  ./scripts/petit.sh logs -f
USAGE
    exit 1
    ;;
esac
