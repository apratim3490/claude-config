#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Sets up Claude Code config by symlinking from this repo into ~/.claude/
.DESCRIPTION
    Windows equivalent of setup.sh. Requires either:
    - Running as Administrator, OR
    - Developer Mode enabled (Settings > For developers > Developer Mode)
#>

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"

if (-not (Test-Path $ClaudeDir)) {
    New-Item -ItemType Directory -Path $ClaudeDir | Out-Null
}

# Directories to symlink
$dirs = @(
    "agents", "rules", "commands", "contexts", "hooks",
    "mcp-configs", "schemas", "scripts", "skills", "tests",
    "plugins", "examples", "guides", "assets"
)

foreach ($dir in $dirs) {
    $source = Join-Path $ScriptDir $dir
    $target = Join-Path $ClaudeDir $dir

    if (Test-Path $source) {
        if (Test-Path $target) {
            # Remove existing symlink or directory
            $item = Get-Item $target -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                $item.Delete()
            } else {
                Remove-Item $target -Recurse -Force
            }
        }
        New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
        Write-Host "Linked $dir/"
    }
}

# Individual files to symlink
$files = @("CLAUDE.md", "settings.json", "package-manager.json")

foreach ($file in $files) {
    $source = Join-Path $ScriptDir $file
    $target = Join-Path $ClaudeDir $file

    if (Test-Path $source) {
        if (Test-Path $target) {
            $item = Get-Item $target -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                $item.Delete()
            } else {
                Remove-Item $target -Force
            }
        }
        New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
        Write-Host "Linked $file"
    }
}

Write-Host "Done. Claude Code config is now synced from $ScriptDir"
