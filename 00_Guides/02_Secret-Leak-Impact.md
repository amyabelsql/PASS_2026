# 2. What Happens When a Secret Gets Committed

This walkthrough is the **why this matters** part of the presentation. It explains the fallout from committing passwords or secrets and gives you a safe way to reproduce the problem.

## Goal

Show that a leaked secret is a security incident, not just a cleanup task.

## Why checking in secrets is bad

Once a secret lands in git, the problem spreads fast:

1. The secret is stored in commit history, not just the latest file.
2. Anyone with access to the repo, fork, clone, cache, or artifact may retain it.
3. Automated scanners look for exposed credentials quickly.
4. Deleting the file later does not make the original exposure disappear.
5. If the secret was real, you must assume it is compromised.

## Safe reproduction for a public demo

Use a **fake sample credential** that is already published in vendor docs. Do not use any real password, key, token, or connection string.

## Demo: prove that a deleted secret still exists in history

Run this on a throwaway branch:

```bash
git switch -c demo/secret-history
cat > demo-secret.env <<'EOF'
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
EOF
git add demo-secret.env
SKIP=gitleaks git commit -m "demo: add fake secret"
rm demo-secret.env
git add -u
git commit -m "demo: remove fake secret"
```

Then prove the secret is still in history:

```bash
git log --oneline -- demo-secret.env
git show HEAD~1:demo-secret.env
```

## What this proves

1. The latest version of the repo can be clean while history is still dirty.
2. A local hook helps, but it can be bypassed.
3. You need layered controls, not one control.

## If you want to show GitHub catching it too

Push the throwaway branch and open a pull request. The secret scanning workflow should flag the fake credential in CI.

## What to say about the fallout

If the leaked value had been real, the response is immediate:

1. Revoke or rotate the secret.
2. Check where that credential was used.
3. Remove the secret from code and possibly from git history.
4. Treat copies in forks, local clones, logs, screenshots, and artifacts as part of the incident scope.

## Cleanup after the demo

Delete the demo branch when you are done:

```bash
git switch main
git branch -D demo/secret-history
rm -f demo-secret.env
```
