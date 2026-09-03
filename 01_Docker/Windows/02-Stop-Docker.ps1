#Requires -Version 5.1
<#
.SYNOPSIS
    Stop and remove the SQL Server Docker container.

.DESCRIPTION
    Equivalent to stop.sh for Windows. Stops and removes the SQL Server
    container without uninstalling Docker.

.EXAMPLE
    .\Docker\stop.ps1
    .\Docker\stop.ps1 -Container pass-test

.NOTES
    Author: DBA Garage Contributors
#>
[CmdletBinding()]
param(
    [string] $Container = 'pass-test'
)

$ErrorActionPreference = 'Stop'

function Section { param([string]$T) Write-Host "`n--  $T" -ForegroundColor Cyan }
function Ok      { param([string]$M) Write-Host "  [OK]   $M" -ForegroundColor Green }
function Info    { param([string]$M) Write-Host "  [..]   $M" }
function Fail    { param([string]$M) Write-Host "  [FAIL] $M" -ForegroundColor Red; exit 1 }

Section "Stop SQL Server"

# Check Docker is available
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Fail "Docker not found"
}

# Check Docker is running
try {
    $null = docker info 2>&1
    if ($LASTEXITCODE -ne 0) { Fail "Docker daemon not running" }
} catch {
    Fail "Docker daemon not running"
}

# Check if container exists and remove it
$allContainers = docker ps -a --format '{{.Names}}' 2>&1
if ($allContainers -contains $Container) {
    docker rm -f $Container 2>&1 | Out-Null
    Ok "Container '$Container' removed"
} else {
    Info "Container '$Container' does not exist - nothing to do"
}

# Remove the SQL Server image
$image = 'mcr.microsoft.com/mssql/server:2022-latest'
$existingImage = docker images -q $image 2>&1
if ($existingImage) {
    docker rmi $image 2>&1 | Out-Null
    Ok "Image '$image' removed"
} else {
    Info "Image '$image' not present - nothing to do"
}
