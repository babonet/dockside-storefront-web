#!/usr/bin/env bash
set -euo pipefail

SINCE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
gh workflow run deploy.yml --ref main -f reason="rollback for incident ${INCIDENT}" -f verification=true

RUN_ID=""
for i in $(seq 1 40); do
  sleep 3
  RUN_ID=$(gh run list --workflow deploy.yml --event workflow_dispatch --limit 5 --json databaseId,createdAt \
    --jq "map(select(.createdAt >= \"${SINCE}\")) | first | .databaseId // empty")
  [ -n "$RUN_ID" ] && break
done
[ -n "$RUN_ID" ] || { echo "Redeploy run not found"; exit 1; }

echo "Watching redeploy run ${RUN_ID}"
gh run watch "$RUN_ID" --exit-status --interval 5
echo "Redeploy verified: ${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${RUN_ID}" >> "$GITHUB_STEP_SUMMARY"
