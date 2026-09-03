#requires -Version 5.1
<#
.SYNOPSIS
    Remove Docker and SQL Server container on Windows.

.DESCRIPTION
    Runs the platform-specific removal script to clean up Docker
    and optionally uninstall it.

.EXAMPLE
    .\Docker\remove.ps1

.NOTES
    Author: DBA Garage Contributors
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$removeScript = Join-Path $scriptDir "06-Remove-Docker.ps1"

if (-not (Test-Path $removeScript)) {
    Write-Error "Remove script not found at: $removeScript"
    exit 1
}

Write-Host "WARNING: This will quit and uninstall Docker Desktop from your system." -ForegroundColor Yellow
$confirm = Read-Host "Continue? (y/N)"

if ($confirm -match '^[Yy]') {
    & $removeScript
    exit $LASTEXITCODE
} else {
    Write-Host "Cancelled." -ForegroundColor Cyan
    exit 0
}
