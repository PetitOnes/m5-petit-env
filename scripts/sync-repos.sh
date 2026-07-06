#!/usr/bin/env bash
# PetitOnesの各コンポーネントリポジトリを repos/ に clone / pull する。
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPOS_DIR="$ROOT_DIR/repos"
ORG_URL_BASE="https://github.com/PetitOnes"

if [ -f "$ROOT_DIR/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT_DIR/.env"
  set +a
fi

mkdir -p "$REPOS_DIR"

sync_repo() {
  local name="$1" branch="$2"
  local url="$ORG_URL_BASE/$name.git"
  local path="$REPOS_DIR/$name"

  if [ -d "$path/.git" ]; then
    echo "Updating $name ($branch)..."
    git -C "$path" fetch origin "$branch"
    git -C "$path" checkout "$branch"
    git -C "$path" pull --ff-only origin "$branch"
  else
    echo "Cloning $name ($branch)..."
    git clone --branch "$branch" "$url" "$path"
  fi

  if [ -f "$path/pyproject.toml" ] && command -v uv >/dev/null 2>&1; then
    echo "uv sync: $name"
    (cd "$path" && uv sync) || echo "警告: $name の uv sync に失敗(後で確認してください)" >&2
  fi
}

sync_repo "m5-petit-mcp"    "${M5_PETIT_MCP_BRANCH:-main}"
sync_repo "m5-petit-app"    "${M5_PETIT_APP_BRANCH:-main}"
sync_repo "m5-petit-memory" "${M5_PETIT_MEMORY_BRANCH:-main}"
sync_repo "m5-petit-desire" "${M5_PETIT_DESIRE_BRANCH:-main}"
sync_repo "m5-petit-scripts" "${M5_PETIT_SCRIPTS_BRANCH:-main}"

# 音声(TTS/ASR)はオプション。WITH_SPEECH=1のときだけ取得する(GPUプロファイル用)。
if [ "${WITH_SPEECH:-0}" = "1" ]; then
  sync_repo "m5-petit-speech" "${M5_PETIT_SPEECH_BRANCH:-main}"
  sync_repo "m5-petit-voice-recognition" "${M5_PETIT_VOICE_RECOGNITION_BRANCH:-main}"
fi

echo "sync-repos.sh 完了"
