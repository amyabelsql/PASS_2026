# Copilot CLI

## Overview

Copilot CLI runs GitHub Copilot in your terminal. You type what you want in plain English, such as "run the SQL tests and tell me what failed", and Copilot works out the commands. It asks before it runs anything that changes or executes a file.

## Value for DBAs

- Use git, gh, sqlcmd, and make without remembering every flag
- Ask it to explain a failed test run or a long error message
- Good for DBAs who are new to the command line

## What it does and does not do

| Does | Does not |
| --- | --- |
| Reads files in the folder you start it in | Run commands without asking, unless you allow a tool for the session |
| Runs commands such as git, gh, make, and sqlcmd after you approve them | Know your passwords, keep them in `.env` and never paste them in |
| Lets you approve a command once, for the session, or reject it | Undo a command after you approve it |
| Works with the same GitHub account and Copilot plan | Work if your org has turned Copilot CLI off |

## What you need

| Item | What to know |
| --- | --- |
| Copilot plan | All plans include Copilot CLI, including Free |
| macOS or Linux | Homebrew or the install script |
| Windows | WinGet and PowerShell 6 or later |

## How to create it

1. Install it with one of these.

```bash
brew install --cask copilot-cli
```

```powershell
winget install GitHub.Copilot
```

2. In a terminal, go to the repo folder and type `copilot`.
3. Sign in with your GitHub account when it asks.

## How to use it

1. From the repo folder, type `copilot`.
2. Ask `Run make test and explain any failures.`
3. Read each command it wants to run and choose to allow it once, allow it for the session, or reject it.

## If it does not work

| What you see | What to do |
| --- | --- |
| `copilot: command not found` | Close and reopen the terminal, or run the install again |
| It says Copilot CLI is disabled | Your org or enterprise owner has turned it off |
| It wants to run something you do not understand | Reject it and ask it to explain the command first |
