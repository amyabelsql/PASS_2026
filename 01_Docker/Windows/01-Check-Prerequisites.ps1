#requires -Version 5.1
<#
.SYNOPSIS
    Run prerequisite checks for the DBA Garage toolkit.

.DESCRIPTION
    Automatically detects whether you are on Windows or macOS and verifies
    that everything needed to use DBA Garage is installed and ready:

      - Operating system (Windows 10/11 or macOS)
      - PowerShell version
      - Git
      - Docker (required on macOS, optional on Windows)

.EXAMPLE
    pwsh -File PreChecks\Invoke-PreChecks.ps1

    Run from the repo root on either platform. No parameters needed.

.NOTES
    Author: DBA Garage Contributors
    Date: 2026-06-09
#>
[CmdletBinding()]
param()

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------
function Write-Heading {
    param([string]$Message)
    Write-Host "`n$Message" -ForegroundColor Cyan
    Write-Host ("-" * $Message.Length) -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message)
    Write-Host "  [OK]   $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  [WARN] $Message" -ForegroundColor Yellow
}

function Write-Fail {
    param([string]$Message)
    Write-Host "  [FAIL] $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "  [INFO] $Message" -ForegroundColor White
}

# ---------------------------------------------------------------------------
# Result tracking
# ---------------------------------------------------------------------------
$script:passed   = 0
$script:warnings = 0
$script:failed   = 0

function Register-Result {
    param(
        [bool]$Success,
        [bool]$IsWarning = $false
    )
    if ($Success) {
        $script:passed++
    } elseif ($IsWarning) {
        $script:warnings++
    } else {
        $script:failed++
    }
}

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   DBA Garage - Prerequisite Checker" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# Detect operating system
# ---------------------------------------------------------------------------
Write-Heading "Operating System  (supported platform check)"

$runningOnWindows = $IsWindows -or ($PSVersionTable.PSVersion.Major -eq 5)
$runningOnMac     = $IsMacOS

if ($runningOnWindows) {
    $osInfo    = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    $osCaption = if ($osInfo) { "$($osInfo.Caption) ($($osInfo.Version))" } else { "Windows" }
    Write-Info "OS: $osCaption"

    if ($osCaption -match "Windows (10|11)|Server (2019|2022|2025)") {
        Write-Ok "Supported Windows version detected"
        Register-Result -Success $true
    } else {
        Write-Warn "Windows 10, 11, or Server 2019+ recommended (some features may work on older versions)"
        Register-Result -Success $false -IsWarning $true
    }
} elseif ($runningOnMac) {
    $swVers = sw_vers -productVersion 2>$null
    Write-Info "OS: macOS $swVers"
    Write-Ok "macOS detected"
    Register-Result -Success $true
} else {
    $osDesc = if ($IsLinux) { "Linux" } else { "Unknown OS" }
    Write-Info "OS: $osDesc"
    Write-Warn "Untested platform. Most checks will still run."
    Register-Result -Success $false -IsWarning $true
}

# ---------------------------------------------------------------------------
# PowerShell version
# ---------------------------------------------------------------------------
Write-Heading "PowerShell  (5.1+ required by all scripts)"
$psVersion = $PSVersionTable.PSVersion

if ($psVersion.Major -ge 5) {
    Write-Ok "PowerShell $($psVersion.Major).$($psVersion.Minor) installed"
    Register-Result -Success $true
} else {
    Write-Fail "PowerShell 5.1+ required - upgrade before running any scripts"
    Write-Info "Download: https://github.com/PowerShell/PowerShell/releases"
    Register-Result -Success $false
}

# ---------------------------------------------------------------------------
# Git
# ---------------------------------------------------------------------------
Write-Heading "Git  (clone and update this repository)"
try {
    $gitVersion = git --version 2>$null
    if ($gitVersion) {
        Write-Ok "Git installed: $gitVersion"
        Register-Result -Success $true
    } else {
        throw
    }
} catch {
    Write-Fail "Git not found - required to clone and update this repository"
    if ($runningOnMac) {
        Write-Info "Install via Xcode CLI tools: xcode-select --install"
        Write-Info "Or via Homebrew:             brew install git"
    } else {
        Write-Info "Download: https://git-scm.com/download/win"
    }
    Register-Result -Success $false
}

# ---------------------------------------------------------------------------
# Make (required to run make check, make start, etc.)
# ---------------------------------------------------------------------------
Write-Heading "Make  (required to run all make commands)"
$makeFound = $null -ne (Get-Command make -ErrorAction SilentlyContinue)
if ($makeFound) {
    Write-Ok "Make installed"
    Register-Result -Success $true
} elseif ($runningOnWindows) {
    Write-Warn "Make not found - installing via winget..."
    try {
        winget install --id GnuWin32.Make --silent --accept-package-agreements --accept-source-agreements | Out-Null

        $gnuMakePath = 'C:\Program Files (x86)\GnuWin32\bin'
        if (Test-Path $gnuMakePath) {
            $machinePath = [System.Environment]::GetEnvironmentVariable('PATH', 'Machine')
            if ($machinePath -notlike "*GnuWin32*") {
                [System.Environment]::SetEnvironmentVariable('PATH', "$machinePath;$gnuMakePath", 'Machine')
            }
            $env:PATH = "$env:PATH;$gnuMakePath"
        }

        if ($null -ne (Get-Command make -ErrorAction SilentlyContinue)) {
            Write-Ok "Make installed and ready"
            Register-Result -Success $true
        } else {
            Write-Ok "Make installed - open a new terminal then run: make check"
            Register-Result -Success $true
        }
    } catch {
        Write-Fail "Could not install make - run manually: winget install GnuWin32.Make"
        Register-Result -Success $false
    }
} else {
    Write-Fail "Make not found - install via: xcode-select --install (macOS) or apt install make (Linux)"
    Register-Result -Success $false
}

# ---------------------------------------------------------------------------
# SqlServer PowerShell module (required by all diagnostic scripts)
# ---------------------------------------------------------------------------
Write-Heading "SqlServer PowerShell Module  (required by all diagnostic scripts)"

Write-Info "Checking installed modules..."
$sqlModule = Get-Module -ListAvailable -Name SqlServer | Sort-Object Version -Descending | Select-Object -First 1
if ($sqlModule) {
    Write-Ok "SqlServer module installed: v$($sqlModule.Version)"
    Register-Result -Success $true
} else {
    Write-Fail "SqlServer module not found - required to run all diagnostic scripts"
    $answer = Read-Host "  Install it now? (y/N)"
    if ($answer -match '^[Yy]') {
        try {
            if ($runningOnWindows) {
                Write-Info "Ensuring NuGet provider is available..."
                Get-PackageProvider -Name NuGet -ForceBootstrap -Force -ErrorAction SilentlyContinue | Out-Null
                Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue
            }
            Write-Info "Downloading SqlServer module from PowerShell Gallery..."
            Install-Module -Name SqlServer -Scope CurrentUser -Force -AllowClobber -Confirm:$false
            Write-Ok "SqlServer module installed successfully"
            Register-Result -Success $true
        } catch {
            Write-Fail "Installation failed: $($_.Exception.Message)"
            Register-Result -Success $false
        }
    } else {
        Write-Info "Skipped - run manually:  Install-Module SqlServer -Scope CurrentUser"
        Register-Result -Success $false
    }
}

# ---------------------------------------------------------------------------
# Docker
# ---------------------------------------------------------------------------
if ($runningOnMac) {
    Write-Heading "Docker  (required on macOS - SQL Server runs in a container)"
} else {
    Write-Heading "Docker  (optional - for running a local SQL Server container)"
}

$dockerFound = $false
try {
    $dockerVersion = docker --version 2>$null
    if ($LASTEXITCODE -eq 0 -and $dockerVersion) {
        Write-Ok "Docker installed: $dockerVersion"
        $dockerFound = $true

        Write-Info "Checking Docker daemon..."
        $null = docker info 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "Docker daemon is running"
            Register-Result -Success $true
        } elseif ($runningOnMac) {
            Write-Warn "Docker is installed but not running - start Docker Desktop"
            Register-Result -Success $false -IsWarning $true
        } else {
            Write-Info "Docker is installed but not running - start Docker Desktop if you need a local container"
            Register-Result -Success $true
        }
    } else {
        throw
    }
} catch {
    if ($runningOnMac) {
        Write-Warn "Docker not found - required on macOS to run a local SQL Server container"
        Write-Info "Download Docker Desktop: https://www.docker.com/products/docker-desktop/"
        Write-Info "Then follow the setup guide: 01_Docker/Mac/README.md"
        Register-Result -Success $false -IsWarning $true
    } else {
        Write-Info "Docker not found (optional - only needed for a local SQL Server container)"
        Write-Info "See Docker/Windows/ folder for installation scripts"
    }
}

# ---------------------------------------------------------------------------
# Disk space (only relevant when Docker is present or needed)
# ---------------------------------------------------------------------------
if ($dockerFound -or $runningOnMac) {
    Write-Heading "Disk Space  (SQL Server container needs ~6 GB minimum)"

    try {
        if ($runningOnWindows) {
            $sysDrive = $env:SystemDrive
            $disk     = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$sysDrive'" -ErrorAction Stop
            $freeGB   = [math]::Round([double]$disk.FreeSpace / 1073741824, 1)
            $driveLabel = $sysDrive
        } else {
            $freeBytes  = osascript -e 'tell application "Finder" to get the free space of startup disk' 2>$null
            if ($freeBytes -match '[\d\.E\+]+') {
                $freeGB = [math]::Round([double]$freeBytes / 1073741824, 1)
            } else {
                $freeKB = [long]($(df -k $HOME 2>$null | tail -1 | awk '{print $4}'))
                $freeGB = [math]::Round($freeKB / 1048576.0, 1)
            }
            $driveLabel = "startup disk"
        }

        Write-Info "Free space available to Docker: $freeGB GB"

        if ($freeGB -ge 10) {
            Write-Ok "$freeGB GB free - sufficient for Docker and SQL Server"
            Register-Result -Success $true
        } elseif ($freeGB -ge 6) {
            Write-Warn "$freeGB GB free - enough to start, but 10 GB+ recommended"
            Write-Info "To free up space: Apple menu > System Settings > General > Storage"
            Write-Info "Or remove unused Docker images: docker system prune"
            Register-Result -Success $false -IsWarning $true
        } else {
            Write-Fail "$freeGB GB free - not enough to run a SQL Server container (minimum 6 GB required)"
            if ($runningOnMac) {
                Write-Info "To free up space:"
                Write-Info "  - Apple menu > System Settings > General > Storage"
                Write-Info "  - Remove unused Docker images: docker system prune"
                Write-Info "  - Or change Docker disk location: Docker Desktop > Settings > Resources > Disk image location"
            } else {
                Write-Info "To fix this:"
                Write-Info "  - Open Disk Management and extend the $driveLabel volume"
                Write-Info "  - Or move Docker data: Docker Desktop > Settings > Resources > Disk image location"
                Write-Info "  - Or free up space: cleanmgr.exe, or docker system prune"
            }
            Register-Result -Success $false
        }
    } catch {
        Write-Warn "Could not determine free disk space: $($_.Exception.Message)"
        Register-Result -Success $false -IsWarning $true
    }
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
Write-Heading "Summary"
Write-Host "  Passed:   $script:passed"   -ForegroundColor Green
Write-Host "  Warnings: $script:warnings" -ForegroundColor Yellow
if ($script:failed -gt 0) {
    Write-Host "  Failed:   $script:failed" -ForegroundColor Red
}

Write-Host ""
if ($script:failed -eq 0 -and $script:warnings -eq 0) {
    Write-Host "All prerequisites met! You are ready to use DBA Garage." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:"
    if ($runningOnMac) {
        Write-Host "  1. Start Docker Desktop and confirm your SQL Server container is running"
        Write-Host "  2. Review README.md for available modules"
        Write-Host "  3. Check index.md to find modules by problem type"
        Write-Host "  4. Run diagnostic scripts from the module folders"
    } else {
        Write-Host "  1. Review README.md for available modules"
        Write-Host "  2. Check index.md to find modules by problem type"
        Write-Host "  3. Run diagnostic scripts from the module folders"
    }
} elseif ($script:failed -eq 0) {
    Write-Host "Prerequisites mostly met. Some optional components are missing." -ForegroundColor Yellow
    Write-Host "You can still use T-SQL scripts directly with any SQL Server tool."
} else {
    Write-Host "Some required prerequisites are missing." -ForegroundColor Red
    Write-Host "Install the missing components listed above to use all DBA Garage features."
}

Write-Host ""
exit $script:failed
