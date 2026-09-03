#Requires -Version 5.1
# SQL Server in Docker smoke test for Windows. Run with:
#   PowerShell -ExecutionPolicy Bypass -File 04-Test-Docker.ps1
# Verifies the container is running and can serve queries.
# Optional parameters:
#   .\04-Test-Docker.ps1 -Container pass-test -Port 1433 -SaPassword 'set-a-strong-password' -DbName PlayGround

[CmdletBinding()]
param(
    [string] $Container  = 'pass-test',
    [int]    $Port       = 1433,
    [string] $SaUsername = 'sa',
    [string] $SaPassword = '',
    [string] $DbName     = 'AdventureWorks2022',
    [string] $TestTable  = '_DockerSmokeTest'
)

$script:Failures = 0
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

function Section { param([string]$T) Write-Host "`n$T" -ForegroundColor Cyan }
function Ok      { param([string]$M) Write-Host "  [OK]   $M" -ForegroundColor Green }
function Info    { param([string]$M) Write-Host "  [..]   $M" }
function Warn    { param([string]$M) Write-Host "  [WARN] $M" -ForegroundColor Yellow }
function Fail    { param([string]$M) Write-Host "  [FAIL] $M" -ForegroundColor Red; $script:Failures++ }

if (-not $SaPassword) {
    $SaPassword = $env:SA_PASSWORD
}
if (-not $SaPassword) {
    Fail "SA_PASSWORD is not set. Copy .env.example to .env or pass -SaPassword."
    Section "Summary"
    Write-Host "  [FAIL] $($script:Failures) check(s) failed" -ForegroundColor Red
    exit $script:Failures
}

function Docker-Running {
    if (Test-Path '\\.\pipe\docker_engine') { return $true }
    $null = docker info 2>&1
    return ($LASTEXITCODE -eq 0)
}

function Run-Sqlcmd {
    param([string]$Query, [string]$Database = '', [switch]$Raw)
    $args18 = @('-i', $Container, '/opt/mssql-tools18/bin/sqlcmd', '-No', '-S', 'localhost', '-U', $SaUsername, '-P', $SaPassword)
    $args14 = @('-i', $Container, '/opt/mssql-tools/bin/sqlcmd',   '-S', 'localhost', '-U', $SaUsername, '-P', $SaPassword)
    if ($Database) { $args18 += @('-d', $Database); $args14 += @('-d', $Database) }
    if ($Raw)      { $args18 += @('-h', '-1', '-W'); $args14 += @('-h', '-1', '-W') }
    $args18 += @('-Q', $Query)
    $args14 += @('-Q', $Query)

    $out = docker exec @args18 2>&1
    if ($LASTEXITCODE -ne 0) {
        $out = docker exec @args14 2>&1
    }
    return [PSCustomObject]@{ Success = ($LASTEXITCODE -eq 0); Output = ($out -join "`n").Trim() }
}

Section "Prerequisites"
$dockerCmd = Get-Command docker -ErrorAction SilentlyContinue
if (-not $dockerCmd) {
    Fail "Docker not found - run 01-Install-Docker.ps1 first"
}
elseif (-not (Docker-Running)) {
    Fail "Docker daemon not running - start Docker Desktop"
}
else {
    Ok "Docker is running"
}

if ($script:Failures -ne 0) {
    Section "Summary"
    Write-Host "  [FAIL] $($script:Failures) check(s) failed" -ForegroundColor Red
    exit $script:Failures
}

Section "Container"
$allContainers = docker ps -a --format '{{.Names}}' 2>&1
if ($allContainers -notcontains $Container) {
    Fail "Container '$Container' does not exist - run 02-Start-Docker.ps1 first"
}
else {
    $running = docker inspect -f '{{.State.Running}}' $Container 2>&1
    if ($running -ne 'true') {
        Fail "Container '$Container' exists but is not running - start it with: docker start $Container"
    }
    else {
        Ok "Container '$Container' is running"
    }
}

Section "Port Mapping"
if ($script:Failures -eq 0) {
    $mapped = docker port $Container '1433/tcp' 2>&1 | Select-Object -First 1
    if ($mapped) { Ok "1433/tcp -> $mapped" }
    else         { Warn "No published port found for 1433/tcp" }
}

Section "Connectivity"
if ($script:Failures -eq 0) {
    $r = Run-Sqlcmd -Query "SELECT 1"
    if ($r.Success) { Ok "sqlcmd connected as '$SaUsername'" }
    else            { Fail "Could not connect with sqlcmd (check SaPassword)" }
}

Section "Server Info"
if ($script:Failures -eq 0) {
    $ver = Run-Sqlcmd -Query "SET NOCOUNT ON; SELECT CONVERT(varchar(20), SERVERPROPERTY('ProductVersion'))" -Raw
    $edi = Run-Sqlcmd -Query "SET NOCOUNT ON; SELECT CONVERT(varchar(50),  SERVERPROPERTY('Edition'))"        -Raw
    $verVal = ($ver.Output -split "`n" | Where-Object { $_ -match '\S' } | Select-Object -First 1).Trim()
    $ediVal = ($edi.Output -split "`n" | Where-Object { $_ -match '\S' } | Select-Object -First 1).Trim()
    if ($verVal) { Ok "Version: $verVal" } else { Warn "Could not read version" }
    if ($ediVal) { Ok "Edition: $ediVal" } else { Warn "Could not read edition" }
}

Section "Database '$DbName'"
if ($script:Failures -eq 0) {
    $r = Run-Sqlcmd -Query "SET NOCOUNT ON; IF DB_ID('$DbName') IS NULL RAISERROR('missing',16,1);"
    if ($r.Success) {
        Ok "Database exists"

        # Check if database has data (tables) - consistent with test.sh
        $tableCheck = Run-Sqlcmd -Query "SET NOCOUNT ON; SELECT COUNT(*) FROM $DbName.sys.tables" -Raw
        $tableCount = 0
        if ($tableCheck.Success) {
            $tableCount = ($tableCheck.Output -split "`n" | Where-Object { $_ -match '^\s*\d+\s*$' } | Select-Object -First 1).Trim() -as [int]
        }

        if ($tableCount -gt 0) {
            Info "Database has $tableCount tables (restored from backup)"
        }
        else {
            Fail "Database is EMPTY - AdventureWorks2022 backup was not restored"
            Write-Host ""
            Write-Host "  To restore the database, run:" -ForegroundColor Yellow
            Write-Host "    make setup" -ForegroundColor Cyan
            $script:Failures++
        }
    }
    else {
        Fail "Database '$DbName' not found"
        Write-Host ""
        Write-Host "  To set up the database, run:" -ForegroundColor Yellow
        Write-Host "    make setup" -ForegroundColor Cyan
        $script:Failures++
    }
}

Section "Read / Write Test"
if ($script:Failures -eq 0) {
    $sql = @"
SET NOCOUNT ON;
IF OBJECT_ID('dbo.$TestTable','U') IS NOT NULL DROP TABLE dbo.$TestTable;
CREATE TABLE dbo.$TestTable (id INT IDENTITY PRIMARY KEY, note NVARCHAR(50), created_at DATETIME2 DEFAULT SYSUTCDATETIME());
INSERT INTO dbo.$TestTable (note) VALUES (N'hello'), (N'world');
SELECT COUNT(*) FROM dbo.$TestTable;
DROP TABLE dbo.$TestTable;
"@
    $r = Run-Sqlcmd -Query $sql -Database $DbName -Raw
    $count = ($r.Output -split "`n" | Where-Object { $_ -match '^\s*\d+\s*$' } | Select-Object -First 1).Trim()
    if ($count -eq '2') {
        Ok "Created table, inserted 2 rows, read them back, dropped table"
    }
    else {
        Fail "Read/write test failed (expected 2 rows, got '$($count -replace '','none')')"
    }
}

Section "Summary"
if ($script:Failures -eq 0) {
    Write-Host "  [OK]   All tests passed - SQL Server is working" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Connect:  docker exec -it $Container /opt/mssql-tools18/bin/sqlcmd -No -S localhost -U $SaUsername -d $DbName" -ForegroundColor Cyan
}
else {
    Write-Host "  [FAIL] $($script:Failures) check(s) failed" -ForegroundColor Red
}
exit $script:Failures
