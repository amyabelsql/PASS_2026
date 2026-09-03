#Requires -Version 5.1
<#
.SYNOPSIS
    Windows equivalent of dev.sh: spin up SQL Server + build/run dba-garage for local development.

.DESCRIPTION
    Brings up the SQL Server container (via Docker/start.ps1), builds the React
    frontend and Go binary natively, then runs the app with pre-filled connection
    info. Ctrl+C stops the app and tears down the container.

.EXAMPLE
    .\dev.ps1
    .\dev.ps1 -SqlPort 1434 -AppPort 8081
    .\dev.ps1 -UiHost 'myserver,1433' -UiUsername 'sa'
#>
[CmdletBinding()]
param(
    [string] $Container    = 'pass-test',
    [int]    $SqlPort      = 1433,
    [string] $SaUsername   = 'sa',
    [string] $SaPassword   = '',
    [int]    $AppPort      = 8080,
    [string] $UiHost       = '',
    [string] $UiUsername   = $SaUsername,
    [string] $UiPassword   = '',
    [string] $UiOutputPath = './'
)

$ErrorActionPreference = 'Continue'
$PSNativeCommandUseErrorActionPreference = $false

$ScriptDir    = $PSScriptRoot
$ProjectRoot  = Resolve-Path (Join-Path $ScriptDir '..\..')
$EnvFile      = Join-Path $ProjectRoot '.env'
$AppDir       = Join-Path $ProjectRoot 'src'
$WebDir     = Join-Path $AppDir   'web'
$DistDir    = Join-Path $AppDir   'internal\web\static\dist'
$BuildDir   = Join-Path $ScriptDir 'build'
$BinaryPath = Join-Path $BuildDir 'dba-garage.exe'

function Import-DotEnv {
    param([string]$Path)

    if (-not (Test-Path $Path)) { return }

    Get-Content $Path | ForEach-Object {
        if ($_ -match '^\s*(#|$)') { return }

        $parts = $_ -split '=', 2
        if ($parts.Count -ne 2) { return }

        $name = $parts[0].Trim()
        $value = $parts[1].Trim().Trim('"').Trim("'")
        if (-not $name) { return }

        if (-not [System.Environment]::GetEnvironmentVariable($name)) {
            [System.Environment]::SetEnvironmentVariable($name, $value)
        }
    }
}

Import-DotEnv -Path $EnvFile

function Section { param([string]$T) Write-Host "`n==  $T" -ForegroundColor Cyan }
function Ok      { param([string]$M) Write-Host "  [OK]   $M" -ForegroundColor Green }
function Info    { param([string]$M) Write-Host "  [..]   $M" }
function Warn    { param([string]$M) Write-Host "  [WARN] $M" -ForegroundColor Yellow }
function Fail    { param([string]$M) Write-Host "  [FAIL] $M" -ForegroundColor Red; exit 1 }

if (-not $SaPassword) {
    $SaPassword = $env:SA_PASSWORD
}
if (-not $SaPassword) {
    Fail "SA_PASSWORD is not set. Copy .env.example to .env or pass -SaPassword."
}

if (-not $UiHost)     { $UiHost = "localhost,$SqlPort" }
if (-not $UiPassword) { $UiPassword = $SaPassword }

# -- Prerequisites -------------------------------------------------------------
Section "Prerequisites"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Fail "Docker not found. Run 'make setup' or install Docker Desktop."
}
if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
    Fail "Go not found. Install Go 1.23+ from https://go.dev/dl/"
}
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Fail "Node/npm not found. Install Node.js 22+ from https://nodejs.org/"
}
Ok "Docker, Go, and Node found"

# -- SQL Server via start.ps1 --------------------------------------------------
$DockerScript = Join-Path $ScriptDir '02-Start-Docker.ps1'
& $DockerScript `
    -Container $Container `
    -Port $SqlPort `
    -SaUsername $SaUsername `
    -SaPassword $SaPassword
if ($LASTEXITCODE -ne 0) { Fail "SQL Server setup failed" }

# -- Build React frontend ------------------------------------------------------
Section "Building React frontend"
Push-Location $WebDir
try {
    Info "npm install"
    npm install --prefer-offline --no-audit --no-fund 2>&1 | Out-Host
    if ($LASTEXITCODE -ne 0) { Fail "npm install failed" }

    Info "npm run build"
    npm run build 2>&1 | Out-Host
    if ($LASTEXITCODE -ne 0) { Fail "npm run build failed" }
} finally {
    Pop-Location
}

# Copy dist into embed location so Go embed picks it up
if (Test-Path $DistDir) { Remove-Item -Recurse -Force $DistDir }
$DistParent = Split-Path $DistDir
if (-not (Test-Path $DistParent)) {
    New-Item -ItemType Directory -Force -Path $DistParent | Out-Null
}
Copy-Item -Recurse (Join-Path $WebDir 'dist') $DistDir
Ok "Frontend dist copied to $DistDir"

# -- Build Go binary -----------------------------------------------------------
Section "Compiling Go binary"
if (-not (Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
}
Push-Location $AppDir
try {
    go build -ldflags="-s -w" -o $BinaryPath .
    if ($LASTEXITCODE -ne 0) { Fail "go build failed" }
} finally {
    Pop-Location
}
Ok "Binary ready at $BinaryPath"

# -- Run -----------------------------------------------------------------------
Section "Starting dba-garage"
Info "http://localhost:$AppPort"
Info "Pre-filled connection: $UiHost  /  $UiUsername  ->  $UiOutputPath"
Write-Host "`n  Press Ctrl+C to stop and tear down.`n"

try {
    & $BinaryPath serve `
        --port                $AppPort `
        --prefill-host        $UiHost `
        --prefill-username    $UiUsername `
        --prefill-password    $UiPassword `
        --prefill-output-path $UiOutputPath
} finally {
    Write-Host ""
    Section "Shutting down"
    $running = docker ps --format '{{.Names}}' 2>$null | Where-Object { $_ -eq $Container }
    if ($running) {
        Info "Container '$Container' left running (use 'make stop' to remove)"
    }
}
