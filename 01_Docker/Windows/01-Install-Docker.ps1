#Requires -Version 5.1
[CmdletBinding()]
param(
    [int]    $Port              = 1433,
    [double] $RequiredMemoryGB  = 2,
    [switch] $SkipInstall
)

$script:Failures = 0

function Section { param([string]$T) Write-Host "`n$T" -ForegroundColor Cyan }
function Ok      { param([string]$M) Write-Host "  [OK]   $M" -ForegroundColor Green }
function Warn    { param([string]$M) Write-Host "  [WARN] $M" -ForegroundColor Yellow }
function Fail    { param([string]$M) Write-Host "  [FAIL] $M" -ForegroundColor Red; $script:Failures++ }

if (-not ($IsWindows -or $env:OS -eq 'Windows_NT')) {
    Write-Host "This script is Windows-only. On macOS, run: bash install-docker.sh" -ForegroundColor Yellow
    exit 1
}

function Find-Docker {
    # Check if docker command is available
    $dockerCmd = Get-Command docker -ErrorAction SilentlyContinue
    if ($dockerCmd) { return $dockerCmd }

    # Check common Docker Desktop locations
    $possiblePaths = @(
        "$env:ProgramFiles\Docker\Docker\resources\bin\docker.exe",
        "$env:ProgramFiles\Docker\Docker\docker.exe",
        "$env:LOCALAPPDATA\Docker\docker.exe",
        "$env:ProgramW6432\Docker\Docker\resources\bin\docker.exe"
    )

    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            # Add to PATH for this session
            $binDir = Split-Path $path -Parent
            $env:PATH = "$binDir;$env:PATH"
            return Get-Command docker -ErrorAction SilentlyContinue
        }
    }

    return $null
}

function Docker-Running {
    if (Test-Path '\\.\pipe\docker_engine') { return $true }
    $info = docker info 2>&1
    return ($LASTEXITCODE -eq 0)
}

Section "Environment"
Write-Host "  [..]   OS: Windows, PS $($PSVersionTable.PSVersion)"

Section "Docker"
$docker = Find-Docker

if ($docker) {
    Ok "$(docker --version 2>&1)"
}
elseif ($SkipInstall) {
    Fail "Docker not installed. Install from https://docker.com/products/docker-desktop"
}
else {
    # Check if Docker Desktop is installed but not in PATH
    $desktopExe = "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
    $localDesktopExe = "$env:LOCALAPPDATA\Docker\Docker Desktop.exe"

    if (Test-Path $desktopExe) {
        Write-Host ""
        Write-Host "Docker Desktop is installed but not in PATH." -ForegroundColor Yellow
        Write-Host "  Starting Docker Desktop..." -ForegroundColor Cyan
        Start-Process $desktopExe

        $waited = 0
        while (-not (Docker-Running) -and $waited -lt 180) {
            Start-Sleep 5; $waited += 5
            Write-Host "." -NoNewline
        }
        Write-Host ""

        if (Docker-Running) {
            Ok "Docker started (${waited}s)"
            $docker = Find-Docker
        }
        else {
            Fail "Docker Desktop failed to start after 180s"
        }
    }
    elseif (Test-Path $localDesktopExe) {
        Write-Host ""
        Write-Host "Docker Desktop is installed (user mode) but not in PATH." -ForegroundColor Yellow
        Write-Host "  Starting Docker Desktop..." -ForegroundColor Cyan
        Start-Process $localDesktopExe

        $waited = 0
        while (-not (Docker-Running) -and $waited -lt 180) {
            Start-Sleep 5; $waited += 5
            Write-Host "." -NoNewline
        }
        Write-Host ""

        if (Docker-Running) {
            Ok "Docker started (${waited}s)"
            $docker = Find-Docker
        }
        else {
            Fail "Docker Desktop failed to start after 180s"
        }
    }
    else {
        Write-Host ""
        Write-Host "Docker not found."
        Write-Host "  This will install Docker Desktop via winget."
        $c = Read-Host "Proceed? (Y/N)"

        if ($c -match '^[Yy]') {
            Write-Host "Installing Docker Desktop via winget..."
            winget install -e --id Docker.DockerDesktop --accept-source-agreements --accept-package-agreements --disable-interactivity 2>&1 | Out-Null
            $docker = Find-Docker
            if ($docker) {
                Ok "Docker installed successfully."
                Write-Host ""
                Write-Host "  A reboot is required before Docker will start." -ForegroundColor Yellow
                Write-Host "  After rebooting, re-run this script:" -ForegroundColor Yellow
                Write-Host "    PowerShell -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -ForegroundColor Cyan
                Write-Host ""
                $r = Read-Host "Restart now? (Y/N)"
                if ($r -match '^[Yy]') {
                    Restart-Computer -Force
                }
                exit 0
            }
            if ($LASTEXITCODE -eq -1978335189) {
                Fail "Docker is registered as installed but files not found. Run Remove-Docker.ps1 to clean up, then re-run this script"
            }
            elseif ($LASTEXITCODE -eq -1978335226) {
                # winget not available (Windows Server) - try direct MSI download
                Write-Host ""
                Write-Host "winget not available on Windows Server. Downloading Docker Desktop MSI..." -ForegroundColor Yellow
                $msiUrl = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
                $msiPath = "$env:TEMP\DockerDesktopInstaller.exe"

                try {
                    Write-Host "Downloading from Docker..." -NoNewline
                    Invoke-WebRequest -Uri $msiUrl -OutFile $msiPath -UseBasicParsing
                    Write-Host " OK" -ForegroundColor Green

                    Write-Host "Installing Docker Desktop (this may take a few minutes)..."
                    Start-Process -FilePath $msiPath -ArgumentList "install", "--quiet" -Wait

                    $docker = Find-Docker
                    if ($docker) {
                        Ok "Docker installed successfully."
                        Write-Host ""
                        Write-Host "  A reboot is required before Docker will start." -ForegroundColor Yellow
                        Write-Host "  After rebooting, run 'make setup' again." -ForegroundColor Yellow
                        Write-Host ""
                        exit 0
                    }
                    else {
                        Fail "Install completed but Docker not found. Reboot and try again, or install manually from: https://docker.com/products/docker-desktop"
                    }
                }
                catch {
                    Fail "Download/Install failed: $_. Install manually from: https://docker.com/products/docker-desktop"
                }
            }
            else {
                Fail "Install failed (exit code $LASTEXITCODE). Install manually: https://docker.com/products/docker-desktop"
            }
        }
        else {
            Fail "Install cancelled"
        }
    }
}

Section "Docker Daemon"
$docker = Find-Docker
if (-not $docker) {
    Warn "Skipping - Docker not found"
    $running = $false
}
elseif (Docker-Running) {
    Ok "Daemon running"
    $running = $true
}
else {
    Write-Host "  [..]   Starting Docker Desktop..." -NoNewline
    $exe = "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
    if (Test-Path $exe) { Start-Process $exe }

    $waited = 0
    while (-not (Docker-Running) -and $waited -lt 180) {
        Start-Sleep 5; $waited += 5
        Write-Host "." -NoNewline
    }
    Write-Host ""
    
    if (Docker-Running) { Ok "Started (${waited}s)"; $running = $true }
    else { Fail "Failed to start after 180s"; $running = $false }
}

Section "Port $Port"
if (netstat -ano 2>&1 | Select-String ":$Port\s") { Warn "Port $Port in use" } else { Ok "Available" }

Section "Memory"
$os = Get-CimInstance Win32_OperatingSystem -EA SilentlyContinue
if ($os) {
    $gb = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
    if ($gb -lt $RequiredMemoryGB) { Fail "${gb}GB free (need ${RequiredMemoryGB}GB)" }
    else { Ok "${gb}GB available" }
}
else { Warn "Could not check memory" }

Section "Docker Hub"
if ($running) {
    try { [Net.Dns]::GetHostAddresses('hub.docker.com') | Out-Null; Ok "Reachable" }
    catch { Warn "Not reachable (pulls may fail)" }
}
else { Warn "Skipping - Docker not running" }

Section "Summary"
if ($script:Failures -eq 0) { Write-Host "  [OK]   Docker ready" -ForegroundColor Green }
else { Write-Host "  [FAIL] $($script:Failures) check(s) failed" -ForegroundColor Red }
exit $script:Failures
