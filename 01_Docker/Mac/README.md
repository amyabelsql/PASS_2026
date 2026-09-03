# DBA Garage - macOS Scripts

Run these scripts in order to set up DBA Garage.

## Quick Start

| Step | Script | Purpose |
|------|--------|---------|
| **01** | `01-Check-Prerequisites.sh` | Verify Docker, Go, Node are installed |
| **02** | `01-Install-Docker.sh` | Install Docker Desktop (if needed) |
| **03** | `02-Start-Docker.sh` | Start SQL Server in Docker |
| **04** | `03-Start-SQL-Server.sh` | Start SQL Server with database |
| **05** | `03-Dev-Environment.sh` | **Full dev mode** - SQL Server + build + run app |
| **06** | `04-Test-Docker.sh` | Test the setup |
| **07** | `05-Cleanup.sh` | Stop and remove containers |
| **08** | `06-Remove-Docker.sh` | Uninstall Docker completely |

## Recommended Flow

**First time setup:**
```bash
bash 01-Check-Prerequisites.sh
bash 01-Install-Docker.sh    # Only if Docker not installed
bash 03-Dev-Environment.sh     # Does everything: SQL + build + run
```

**Daily development:**
```bash
bash 03-Dev-Environment.sh
```

## Individual Scripts

- **02-Start-Docker.sh** - Just start SQL Server container
- **03-Start-SQL-Server.sh** - Start SQL Server with AdventureWorks restore
- **04-Test-Docker.sh** - Verify everything is working
