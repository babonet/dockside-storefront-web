#!/usr/bin/env bash
set -euo pipefail

git config user.name "dockside-autopilot"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

SUBJECT=$(git log -1 --format=%s "$SHA")
BRANCH="revert/${SHA::7}"

git checkout -b "$BRANCH"
if [ "$(git rev-list --parents -n 1 "$SHA" | wc -w)" -gt 2 ]; then
  git revert --no-edit -m 1 "$SHA"
else
  git revert --no-edit "$SHA"
fi
git push origin "$BRANCH"

BODY="Automated rollback for Port incident \`${INCIDENT}\`.

Reverts ${SHA} (\"${SUBJECT}\"), the change identified as the trigger of the production smoke-test failure.

- Approved by: ${APPROVED_BY}
- Orchestrated by: Port self-healing incident workflow"

PR_URL=$(gh pr create --base main --head "$BRANCH" --title "Revert \"${SUBJECT}\"" --body "$BODY")
gh pr merge "$PR_URL" --squash --delete-branch

echo "Rollback PR: ${PR_URL}" >> "$GITHUB_STEP_SUMMARY"
