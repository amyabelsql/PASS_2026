# Local SQL Server dev environment — single source of truth for
# container name, SA credentials, database, and ports.
#
# Override any value on the command line, e.g.:
#   make start CONTAINER=myserver SA_PASSWORD='set-a-strong-password'
# Or store SA_PASSWORD in .env (see .env.example).
CONTAINER   ?= pass-test
PORT        ?= 1433
SA_USERNAME ?= sa
SA_PASSWORD ?=
DB_NAME     ?= AdventureWorks2022
IMAGE       ?= mcr.microsoft.com/mssql/server:2022-latest
APP_PORT    ?= 8080

export CONTAINER PORT SA_USERNAME SA_PASSWORD DB_NAME IMAGE APP_PORT

DOCKER_DIR := 01_Docker/Mac

.PHONY: check install start setup dev test stop remove summit-guardrails summit-demo-order

check:
	bash $(DOCKER_DIR)/01-Check-Prerequisites.sh

install:
	bash $(DOCKER_DIR)/01-Install-Docker.sh

start:
	bash $(DOCKER_DIR)/02-Start-Docker.sh

setup:
	bash $(DOCKER_DIR)/03-Start-SQL-Server.sh

dev:
	bash $(DOCKER_DIR)/03-Dev-Environment.sh

test:
	bash $(DOCKER_DIR)/04-Test-Docker.sh

stop:
	bash $(DOCKER_DIR)/05-Cleanup.sh

remove:
	bash $(DOCKER_DIR)/06-Remove-Docker.sh

summit-guardrails:
	bash 05_PASS_Summit_Demos/scripts/sql_guardrails.sh 02_Database/changes/*.sql

summit-demo-order:
	@echo "1) 05_PASS_Summit_Demos/01_Templates_And_Approval_Process.md"
	@echo "2) 05_PASS_Summit_Demos/02_Approvals_And_Automation.md"
	@echo "3) 05_PASS_Summit_Demos/03_Webhooks_And_GitHub_Actions.md"
	@echo "4) 05_PASS_Summit_Demos/04_Documentation.md"
	@echo "5) 05_PASS_Summit_Demos/05_Tips_And_Tricks.md"
