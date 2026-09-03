#Requires -Version 5.1
[CmdletBinding()]
param(
    [string] $Container   = 'pass-test',
    [int]    $Port        = 1433,
    [string] $SaUsername  = 'sa',
    [string] $SaPassword  = '',
    [string] $DbName      = 'AdventureWorks2022',
    [string] $Image       = 'mcr.microsoft.com/mssql/server:2022-latest',
    [switch] $NoRestore
)

$ErrorActionPreference = 'Continue'
$PSNativeCommandUseErrorActionPreference = $false

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$EnvFile = Join-Path $ProjectRoot '.env'

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

function Section { param([string]$T) Write-Host "`n══  $T" -ForegroundColor Cyan }
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

function Docker-Running {
    if (Test-Path '\\.\pipe\docker_engine') { return $true }
    $null = docker info 2>&1
    return ($LASTEXITCODE -eq 0)
}

function Run-Sqlcmd {
    param([string]$Query)
    docker exec -i $Container /opt/mssql-tools18/bin/sqlcmd -No -S localhost -U $SaUsername -P $SaPassword -Q $Query *> $null
    if ($LASTEXITCODE -ne 0) {
        docker exec -i $Container /opt/mssql-tools/bin/sqlcmd -S localhost -U $SaUsername -P $SaPassword -Q $Query *> $null
    }
    return ($LASTEXITCODE -eq 0)
}

# ── Prerequisites ─────────────────────────────────────────────────────────────
Section "Prerequisites"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Fail "Docker not found. Run 'make setup' to install Docker, or install manually from: https://www.docker.com/products/docker-desktop"
}

if (-not (Docker-Running)) {
    Fail "Docker daemon not running. Start Docker Desktop first."
}

Ok "Docker is running"

# ── SQL Server container ──────────────────────────────────────────────────────
Section "SQL Server"

$existing = docker ps -a --format '{{.Names}}' 2>$null | Where-Object { $_ -eq $Container }
$running = docker ps --format '{{.Names}}' 2>$null | Where-Object { $_ -eq $Container }

if ($running) {
    Ok "Container '$Container' already running"
}
elseif ($existing) {
    Info "Starting existing container '$Container'..."
    docker start $Container | Out-Null
    Ok "Container started"
}
else {
    Info "Creating new SQL Server container..."
    Info "Pulling $Image (this may take a minute)..."
    docker pull $Image 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail "Failed to pull Docker image" }
    
    docker run -d `
        --name $Container `
        -e "ACCEPT_EULA=Y" `
        -e "MSSQL_SA_PASSWORD=$SaPassword" `
        -p "${Port}:1433" `
        $Image 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail "Failed to create container" }
    Ok "Container created"
}

# ── Wait for SQL Server ───────────────────────────────────────────────────────
Section "Waiting for SQL Server"
$waited = 0
Write-Host "  [..]   Connecting" -NoNewline
while (-not (Run-Sqlcmd -Query "SELECT 1")) {
    if ($waited -ge 90) {
        Write-Host ""
        Fail "SQL Server did not become ready after 90s"
    }
    Start-Sleep 3; $waited += 3
    Write-Host "." -NoNewline
}
Write-Host ""
Ok "SQL Server ready (${waited}s)"

# ── Check Database ────────────────────────────────────────────────────────────
Section "Database Check"

$dbExists = Run-Sqlcmd -Query "SELECT 1 FROM sys.databases WHERE name = 'AdventureWorks2022'"
$tableCount = 0

if ($dbExists) {
    $tc = docker exec $Container /opt/mssql-tools18/bin/sqlcmd -No -S localhost -U $SaUsername -P $SaPassword -h -1 -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM AdventureWorks2022.sys.tables" 2>$null
    $tcStr = ($tc | Out-String)
    if ($tcStr -match '(\d+)') { $tableCount = [int]$Matches[1] }
}

if ($dbExists -and $tableCount -gt 0) {
    Ok "AdventureWorks2022 ready with $tableCount tables"
}
elseif ($dbExists -and $NoRestore) {
    Warn "Database exists but is empty. Run 'make setup' to restore data."
}
elseif ($NoRestore) {
    Warn "Database not found. Run 'make setup' to create and restore."
}
else {
    # Need to restore
    if ($dbExists) {
        Info "Database empty - dropping for restore..."
        Run-Sqlcmd -Query "DROP DATABASE [AdventureWorks2022];" | Out-Null
        Start-Sleep -Seconds 2
    }

    Info "Downloading AdventureWorks2022 backup (~175MB)..."
    $AwUrl = 'https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2022.bak'
    $AwBak = '/var/opt/mssql/data/AdventureWorks2022.bak'

    docker exec $Container bash -c "apt-get update -qq && apt-get install -y -qq curl" 2>$null | Out-Null
    docker exec $Container curl -fsSL -o $AwBak $AwUrl 2>&1 | Out-Null

    if ($LASTEXITCODE -eq 0) {
        $fs = docker exec $Container stat -c%s $AwBak 2>&1
        if ($fs -match '^\d+$' -and ([int]$fs / 1MB) -gt 100) {
            Info "Restoring database..."
            $sql = "RESTORE DATABASE [AdventureWorks2022] FROM DISK = N'$AwBak' WITH MOVE 'AdventureWorks2022' TO '/var/opt/mssql/data/AdventureWorks2022.mdf', MOVE 'AdventureWorks2022_log' TO '/var/opt/mssql/data/AdventureWorks2022_log.ldf', REPLACE;"
            if (Run-Sqlcmd -Query $sql) {
                Ok "AdventureWorks2022 restored successfully"
                docker exec $Container rm -f $AwBak 2>$null | Out-Null
            }
            else {
                Warn "Restore failed - creating empty database"
                Run-Sqlcmd -Query "CREATE DATABASE [AdventureWorks2022];" | Out-Null
            }
        }
        else {
            Warn "Download incomplete - creating empty database"
            Run-Sqlcmd -Query "CREATE DATABASE [AdventureWorks2022];" | Out-Null
        }
    }
    else {
        Warn "Download failed - creating empty database"
        Run-Sqlcmd -Query "CREATE DATABASE [AdventureWorks2022];" | Out-Null
    }
}

# ── Done ──────────────────────────────────────────────────────────────────────
Section "Done"
Write-Host "  Server:   localhost,$Port" -ForegroundColor Gray
Write-Host "  Database: $DbName" -ForegroundColor Gray
Write-Host "  User:     $SaUsername" -ForegroundColor Gray
Write-Host ""
