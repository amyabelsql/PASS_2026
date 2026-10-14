# Copilot in VS Code

## Overview

VS Code with the Microsoft MSSQL extension connects to SQL Server and works with GitHub Copilot. This is where you write the SQL files that go into the repo. In Copilot chat you type `@mssql` to ask about the connected database, and the extension adds commands such as `/explain`, `/fix`, and `/optimize`.

## Value for DBAs

- Write a change script, test it against the local Docker SQL Server, and commit it from one window
- Copilot sees both the repo and the database schema, so its SQL matches your real tables
- Copilot chat in VS Code also reads the instructions files in `.github/instructions/`

## What it does and does not do

| Does | Does not |
| --- | --- |
| Answers questions about the connected database with `@mssql` | Know which server is production |
| Explains, fixes, and tunes a query with `/explain`, `/fix`, and `/optimize` | Replace the pull request review and the SQL checks |
| Runs queries from chat in agent mode with `/runQuery` | Stop you from running a query on the wrong server |
| Suggests SQL as you type | Work without a Copilot plan |

## What you need

| Item | What to know |
| --- | --- |
| VS Code | Current version with the GitHub Copilot Chat extension |
| MSSQL extension | Version 1.37 or later, where the Copilot features are generally available |
| Copilot plan | Copilot Free works with monthly limits |
| Database | Point it at the local Docker SQL Server from `make setup`, not production |

## How to create it

1. Install VS Code.
2. Click Extensions, search for SQL Server (mssql), and install it.
3. Sign in to GitHub Copilot from the Copilot icon at the top of VS Code.
4. Click the SQL Server icon in the sidebar, click Add Connection, and connect to `localhost` with the login from your `.env` file.

## How to use it

1. Connect to the local database from the SQL Server sidebar.
2. In Copilot chat, ask `@mssql which procedures read from dbo.Orders?`
3. Open a SQL file in `02_Database/changes/`, select a query, and ask Copilot to explain or optimize it.
4. Run the change against the local database, then commit it and open a pull request.

## If it does not work

| What you see | What to do |
| --- | --- |
| `@mssql` is not offered in chat | Update the MSSQL extension to 1.37 or later |
| Copilot does not know your tables | Connect to the database from the SQL Server sidebar first |
| The query ran somewhere you did not expect | Check the connection in the status bar before you run anything |
