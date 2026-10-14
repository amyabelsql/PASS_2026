# Pre-Commit Hooks

## Overview

A pre-commit hook runs checks every time you type `git commit`. If a check fails, the commit does not happen, so the problem never leaves your laptop. This repo uses the pre-commit tool, and [.pre-commit-config.yaml](../.pre-commit-config.yaml) lists the checks.

| Hook | What it stops |
| --- | --- |
| dba-sql-guardrails | Risky SQL in `02_Database/changes/`, see [01_SQL_Guardrails.md](01_SQL_Guardrails.md) |
| gitleaks | Passwords, keys, and tokens |
| detect-private-key | Private key files |
| check-yaml | Broken YAML in workflows and issue forms |
| check-added-large-files | Large files such as backups |
| trailing-whitespace and end-of-file-fixer | Messy whitespace, these fix the file for you |

## Value for DBAs

- A password or a risky DELETE is stopped before it is ever pushed
- Feedback takes seconds instead of waiting for a pull request check
- The same checks run for everyone on the team

## What it does and does not do

| Does | Does not |
| --- | --- |
| Runs on the files you are committing | Run on files you did not change |
| Stops the commit when a check fails | Run for people who have not installed it, so keep the pull request checks too |
| Fixes whitespace for you and asks you to commit again | Run when someone commits with `--no-verify` |

## What you need

The pre-commit tool, which is free. Install it with `brew install pre-commit` on macOS or `pip install pre-commit` anywhere Python is installed.

## How to create it

1. Copy [.pre-commit-config.yaml](../.pre-commit-config.yaml) to the root of your repo.
2. From the repo folder, run `pre-commit install`. This only needs to be done once per clone.
3. Run `pre-commit run --all-files` once to check the whole repo.

## How to use it

1. Commit as usual with `git commit`.
2. If a hook fails, read its message, fix the file, run `git add` again, and commit again.
3. To run the checks without committing, run `pre-commit run`.

## If it does not work

| What you see | What to do |
| --- | --- |
| `files were modified by this hook` | The whitespace hooks fixed the file. Run `git add` on it and commit again. |
| Nothing runs on commit | Run `pre-commit install` in this clone |
| `pre-commit: command not found` | Install it with `brew install pre-commit` |
| The first run is slow | It downloads the hooks once, later runs are fast |
