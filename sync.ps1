<#
.SYNOPSIS
    Daily sync: pull latest config from GitHub and re-run setup.
#>

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogDir = Join-Path $env:LOCALAPPDATA "claude-config"
$LogFile = Join-Path $LogDir "sync.log"

if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

function Write-Log($Message) {
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss 'UTC'")
    "[$timestamp] $Message" | Out-File -Append -FilePath $LogFile
}

Write-Log "--- sync started ---"

Set-Location $ScriptDir

# Abort if there are local uncommitted changes
$status = git diff --quiet HEAD 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Log "SKIPPED: local uncommitted changes detected. Commit or stash first."
    exit 1
}

git pull --ff-only origin main 2>&1 | Out-File -Append -FilePath $LogFile
if ($LASTEXITCODE -ne 0) {
    Write-Log "ERROR: git pull failed (likely diverged). Resolve manually."
    exit 1
}

# Run setup (needs admin for symlinks)
& "$ScriptDir\setup.ps1" 2>&1 | Out-File -Append -FilePath $LogFile
Write-Log "--- sync complete ---"
