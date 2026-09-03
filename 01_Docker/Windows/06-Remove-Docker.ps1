#Requires -Version 5.1
#Requires -RunAsAdministrator

function Section { param([string]$T) Write-Host "`n$T" -ForegroundColor Cyan }
function Ok      { param([string]$M) Write-Host "  [OK]   $M" -ForegroundColor Green }
function Info    { param([string]$M) Write-Host "  [..]   $M" }
function Warn    { param([string]$M) Write-Host "  [WARN] $M" -ForegroundColor Yellow }

Section "Confirm"
Write-Host "  This will uninstall Docker Desktop and remove its config files."
$confirm = Read-Host "Proceed? (Y/N)"
if ($confirm -notmatch '^[Yy]') {
    Write-Host "  [..]   Cancelled"
    exit 0
}

# Kill Docker processes first
Section "Stopping Docker Processes"
Get-Process | Where-Object { $_.Name -match 'docker|com.docker' } | Stop-Process -Force -EA SilentlyContinue
Ok "Processes stopped"

# Uninstall via winget
Section "Uninstalling Docker Desktop"
$winget = Get-Command winget -EA SilentlyContinue
if ($winget) {
    winget uninstall --id Docker.DockerDesktop --silent 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { Ok "Uninstalled via winget" }
    else { Info "winget exit code $LASTEXITCODE (may not be winget-installed)" }
}

# Run uninstaller if present
$uninstaller = "$env:ProgramFiles\Docker\Docker\Docker Desktop Installer.exe"
if (Test-Path $uninstaller) {
    Info "Running uninstaller..."
    $proc = Start-Process $uninstaller -ArgumentList "uninstall","--quiet" -Wait -PassThru
    if ($proc.ExitCode -eq 0) { Ok "Uninstaller completed" }
    else { Warn "Uninstaller exit code $($proc.ExitCode)" }
}

# Remove all traces
Section "Removing Leftover Files"
$paths = @(
    "$env:ProgramFiles\Docker"
    "$env:ProgramData\Docker"
    "$env:APPDATA\Docker"
    "$env:LOCALAPPDATA\Docker"
    "$env:USERPROFILE\.docker"
    "$env:TEMP\DockerDesktop*"
)
foreach ($p in $paths) {
    if (Test-Path $p) {
        Remove-Item $p -Recurse -Force -EA SilentlyContinue
        Info "Removed: $p"
    }
}

# Clean registry entries that winget tracks
Section "Cleaning Registry"
$regPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Docker Desktop'
    'HKLM:\SOFTWARE\Classes\Installer\Products\*Docker*'
    'HKLM:\SOFTWARE\Docker Inc'
    'HKCU:\SOFTWARE\Docker Inc'
)
foreach ($rp in $regPaths) {
    if (Test-Path $rp) {
        Remove-Item $rp -Recurse -Force -EA SilentlyContinue
        Info "Removed: $rp"
    }
}

# Also check winget packages
Info "Purging from winget..."
winget uninstall --id Docker.DockerDesktop --force 2>&1 | Out-Null
Ok "Registry cleaned"

# Clean PATH
Section "Cleaning PATH"
$machinePath = [Environment]::GetEnvironmentVariable('PATH','Machine')
$userPath = [Environment]::GetEnvironmentVariable('PATH','User')
$cleanMachine = ($machinePath -split ';' | Where-Object { $_ -notmatch 'Docker' }) -join ';'
$cleanUser = ($userPath -split ';' | Where-Object { $_ -notmatch 'Docker' }) -join ';'
[Environment]::SetEnvironmentVariable('PATH', $cleanMachine, 'Machine')
[Environment]::SetEnvironmentVariable('PATH', $cleanUser, 'User')
Ok "PATH cleaned"

# Verify
Section "Verification"
$env:PATH = [Environment]::GetEnvironmentVariable('PATH','Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH','User')
$dockerCmd = Get-Command docker -EA SilentlyContinue
$dockerDir = Test-Path "$env:ProgramFiles\Docker"

if ($dockerCmd) { Warn "docker still in PATH" }
else { Ok "docker removed from PATH" }

if ($dockerDir) { Warn "Program Files\Docker still exists" }
else { Ok "Program Files\Docker removed" }

$restart = ($dockerCmd -or $dockerDir)
if ($restart) {
    Warn "REBOOT REQUIRED to complete removal"
}

$r = Read-Host "`nReboot now? (Y/N)"
if ($r -match '^[Yy]') { Restart-Computer -Force }
else { Info "Reboot before re-running Install-Docker.ps1" }
