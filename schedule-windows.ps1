<#
.SYNOPSIS
    Registers a Windows scheduled task to sync claude-config daily at 8:00 AM GMT.
.DESCRIPTION
    Uses schtasks.exe which natively supports timezone specification.
    Must be run as Administrator (needed for both the task and symlink setup).
#>
#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TaskName = "Claude Config Sync"
$SyncScript = Join-Path $ScriptDir "sync.ps1"

# Remove existing task if present
schtasks.exe /Query /TN $TaskName 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Removing existing scheduled task..."
    schtasks.exe /Delete /TN $TaskName /F | Out-Null
}

# Create the task: daily at 08:00 GMT Standard Time, run as current user
schtasks.exe /Create `
    /TN $TaskName `
    /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$SyncScript`"" `
    /SC DAILY `
    /ST 08:00 `
    /RL HIGHEST `
    /F

Write-Host ""
Write-Host "Scheduled: $TaskName"
Write-Host "  Runs daily at 08:00 (system local time)"
Write-Host "  Script: $SyncScript"
Write-Host "  Log:    $env:LOCALAPPDATA\claude-config\sync.log"
Write-Host ""
Write-Host "To uninstall: schtasks.exe /Delete /TN '$TaskName' /F"
Write-Host ""
Write-Host "NOTE: To set GMT explicitly, open Task Scheduler GUI > task properties >"
Write-Host "      Triggers > Edit > check 'Synchronize across time zones'."
