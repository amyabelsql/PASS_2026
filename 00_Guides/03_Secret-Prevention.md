# 3. Preventing Password and Secret Leaks

This walkthrough is the **how we prevent it** part of the presentation.

## Goal

Show a practical defense-in-depth approach for passwords, API keys, tokens, and connection strings.

## Prevention layers in this repo

1. **Do not commit local secrets.** `.env` is ignored, and `.env.example` is the safe template.
2. **Require local scanning before commit.** `.pre-commit-config.yaml` runs `detect-private-key` and `gitleaks`.
3. **Scan again in GitHub.** `.github/workflows/secret-scanning.yml` runs on pull requests and pushes.
4. **Use GitHub Actions secrets in CI.** The SQL workflow reads `SQL_SA_PASSWORD` instead of a hardcoded password.

## Where the protection lives

1. `00_Guides/` explains the process.
2. `.pre-commit-config.yaml` blocks common secret leaks locally.
3. `.github/workflows/secret-scanning.yml` scans in GitHub.
4. `04_Run/run-tests.sh` and the Docker scripts read passwords from environment variables instead of committed values.

## Local setup

```bash
cp .env.example .env
pre-commit install
```

Set a strong password in `.env`:

```dotenv
SA_PASSWORD=replace-with-a-strong-local-password
SQL_PASSWORD=replace-with-a-strong-local-password
```

## How to prove the prevention works

Create a safe fake secret file and scan it:

```bash
cat > demo-secret.env <<'EOF'
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
EOF
pre-commit run --files demo-secret.env
rm demo-secret.env
```

The expected result is that the scan flags the file before commit.

## Password and secret best practices to present

1. Use unique, generated passwords instead of shared defaults.
2. Keep secrets in environment variables, GitHub secrets, or a secrets manager.
3. Give credentials the least privilege they need.
4. Separate local, test, and production credentials.
5. Rotate secrets quickly if there is any chance they were exposed.
6. Never put secrets in sample code, screenshots, slides, or logs.

## If prevention fails

The right response is:

1. Rotate first.
2. Clean up code and history second.
3. Review access and logs third.
4. Tighten the guardrails so it is harder to repeat.
