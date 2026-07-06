# PetitOnesの各コンポーネントリポジトリを repos/ に clone / pull する(Windows PowerShell版)。
$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ReposDir = Join-Path $RootDir "repos"
$EnvPath = Join-Path $RootDir ".env"
$OrgUrlBase = "https://github.com/PetitOnes"

if (Test-Path $EnvPath) {
  Get-Content $EnvPath | ForEach-Object {
    if ($_ -match '^\s*#') { return }
    if ($_ -match '^\s*$') { return }
    $parts = $_ -split '=', 2
    if ($parts.Length -eq 2) {
      [Environment]::SetEnvironmentVariable($parts[0].Trim(), $parts[1].Trim(), 'Process')
    }
  }
}

New-Item -ItemType Directory -Force -Path $ReposDir | Out-Null

function Sync-Repo($Name, $Branch) {
  $Url = "$OrgUrlBase/$Name.git"
  $Path = Join-Path $ReposDir $Name
  $GitDir = Join-Path $Path ".git"

  if (Test-Path $GitDir) {
    Write-Host "Updating $Name ($Branch)..."
    git -C $Path fetch origin $Branch
    git -C $Path checkout $Branch
    git -C $Path pull --ff-only origin $Branch
  } else {
    Write-Host "Cloning $Name ($Branch)..."
    git clone --branch $Branch $Url $Path
  }

  $PyProject = Join-Path $Path "pyproject.toml"
  if ((Test-Path $PyProject) -and (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "uv sync: $Name"
    Push-Location $Path
    try { uv sync } catch { Write-Warning "$Name の uv sync に失敗(後で確認してください)" }
    Pop-Location
  }
}

function Get-BranchEnv($VarName, $Default) {
  $v = [Environment]::GetEnvironmentVariable($VarName)
  if ([string]::IsNullOrEmpty($v)) { return $Default } else { return $v }
}

Sync-Repo "m5-petit-mcp"    (Get-BranchEnv "M5_PETIT_MCP_BRANCH" "main")
Sync-Repo "m5-petit-app"    (Get-BranchEnv "M5_PETIT_APP_BRANCH" "main")
Sync-Repo "m5-petit-memory" (Get-BranchEnv "M5_PETIT_MEMORY_BRANCH" "main")
Sync-Repo "m5-petit-desire" (Get-BranchEnv "M5_PETIT_DESIRE_BRANCH" "main")
Sync-Repo "m5-petit-scripts" (Get-BranchEnv "M5_PETIT_SCRIPTS_BRANCH" "main")

$WithSpeech = Get-BranchEnv "WITH_SPEECH" "0"
if ($WithSpeech -eq "1") {
  Sync-Repo "m5-petit-speech" (Get-BranchEnv "M5_PETIT_SPEECH_BRANCH" "main")
  Sync-Repo "m5-petit-voice-recognition" (Get-BranchEnv "M5_PETIT_VOICE_RECOGNITION_BRANCH" "main")
}

Write-Host "sync-repos.ps1 完了"
