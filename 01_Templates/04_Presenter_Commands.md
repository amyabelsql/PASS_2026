# Presenter Commands

## Overview

These commands build the templates demo before the session and remove it afterwards. Run them from the repo root.

## Before the first run

```bash
gh auth login
gh auth refresh -s project,delete_repo
```

## Commands

| Command | What it does |
| --- | --- |
| `make templates` | Marks this repo as a template, adds labels, and builds the board |
| `make templates-demo` | Creates `pass-dba-demo` from the template with three sample issues on the board |
| `make templates-reset` | Deletes `pass-dba-demo` and its board items |
| `make templates-teardown` | Resets, deletes the board, and turns off the template setting |

## One manual step

After the first `make templates`, open the board and add a Board view grouped by Status. Views cannot be created from the command line.
