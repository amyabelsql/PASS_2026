# AI with Copilot Overview

GitHub Copilot is one AI assistant that follows a DBA from SSMS to the terminal to GitHub. Inside GitHub it summarizes and reviews pull requests and can take an issue and open a pull request on its own. Outside GitHub it writes and explains T-SQL in SSMS and VS Code and runs tasks from the terminal. The same Copilot plan covers all of it.

| File | Where it runs | What a DBA uses it for |
| --- | --- | --- |
| [01_Copilot_on_GitHub.md](01_Copilot_on_GitHub.md) | GitHub website, mobile app, Slack, Teams | Hand an issue to Copilot and get a pull request back |
| [02_Copilot_in_SSMS.md](02_Copilot_in_SSMS.md) | SQL Server Management Studio 22 | Write, explain, and tune T-SQL against a live connection |
| [03_Copilot_in_VS_Code.md](03_Copilot_in_VS_Code.md) | VS Code with the MSSQL extension | Write SQL files for the repo and test them against a dev database |
| [04_Copilot_CLI.md](04_Copilot_CLI.md) | Terminal | Run git, gh, and sqlcmd tasks by asking in plain English |
| [05_Guardrails.md](05_Guardrails.md) | Everywhere | Teach Copilot your rules and keep a human in charge |
| [06_Presenter_Commands.md](06_Presenter_Commands.md) | Demo | Hand an issue to Copilot live with `make ai-demo` |

Copilot reviews and approvals for pull requests are covered in [02_Approval_Process/06_Copilot_Reviews.md](../02_Approval_Process/06_Copilot_Reviews.md).

| Copilot plan | What is included |
| --- | --- |
| Free | Chat, a monthly limit of completions, SSMS, VS Code, and the CLI. No cloud agent and no pull request reviews. |
| Pro, Pro+, Max, Business, Enterprise | Everything in this section |

[Copilot plans](https://github.com/features/copilot/plans)
