# DBA Garage - Windows Scripts

Run these scripts in order to set up DBA Garage.

## Quick Start

| Step | Script | Purpose |
|------|--------|---------|
| **01** | `01-Check-Prerequisites.ps1` | Verify Docker, Go, Node are installed |
| **02** | `01-Install-Docker.ps1` | Install Docker Desktop (if needed) |
| **03** | `02-Start-Docker.ps1` | Start SQL Server in Docker |
| **04** | `02-Stop-Docker.ps1` | Stop SQL Server container |
| **05** | `03-Dev-Environment.ps1` | **Full dev mode** - SQL Server + build + run app |
| **06** | `04-Test-Docker.ps1` | Test the setup |
| **07** | `05-Cleanup.ps1` | Stop and remove containers |
| **08** | `06-Remove-Docker.ps1` | Uninstall Docker completely |

## Recommended Flow

**First time setup:**
```powershell
.\01-Check-Prerequisites.ps1
.\01-Install-Docker.ps1      # Only if Docker not installed
.\03-Dev-Environment.ps1      # Does everything: SQL + build + run
```

**Daily development:**
```powershell
.\03-Dev-Environment.ps1
```

## Individual Scripts

- **02-Start-Docker.ps1** - Just start SQL Server container
- **02-Stop-Docker.ps1** - Stop the SQL Server container
- **03-Dev-Environment-Full.ps1** - Alternative dev script
- **04-Test-Docker.ps1** - Verify everything is working
