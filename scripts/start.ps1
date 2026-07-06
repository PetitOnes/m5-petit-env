$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$EnvPath = Join-Path $RootDir ".env"

if (-not (Test-Path $EnvPath)) {
  Write-Error ".env が見つかりません。.env.example をコピーして作成してください: Copy-Item .env.example .env"
  exit 1
}

& (Join-Path $RootDir "scripts/sync-repos.ps1")
docker compose --env-file $EnvPath up --build
