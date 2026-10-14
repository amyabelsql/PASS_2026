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

.PHONY: check install start setup dev test stop remove summit-guardrails summit-demo-order \
        templates templates-demo templates-reset templates-teardown

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
	bash 04_Automation/scripts/sql_guardrails.sh 02_Database/changes/*.sql

summit-demo-order:
	@echo "00_Guides"
	@echo "01_Templates"
	@echo "02_Approval_Process"
	@echo "04_Automation"
	@echo "05_Webhooks"
	@echo "06_Actions"
	@echo "07_Documentation"
	@echo "08_Tips_and_Tricks"
	@echo "Webinar/00_Guide"
	@echo "Webinar/01_Secrets"

# Templates demo (01_Templates). See 01_Templates/README.md.
templates:
	bash 01_Templates/templates.sh build

templates-demo:
	bash 01_Templates/templates.sh demo

templates-reset:
	bash 01_Templates/templates.sh reset

templates-teardown:
	bash 01_Templates/templates.sh teardown
