#!/usr/bin/env bash
# Raises a production alert as a GitHub issue; Port ingests issues labeled "alert" as alert entities.
set -euo pipefail

SHA=$(git rev-parse HEAD)
SHORT=${SHA::7}
SUBJECT=$(git log -1 --format=%s)
AUTHOR=$(git log -1 --format=%an)
PR=$(echo "$SUBJECT" | grep -oE '#[0-9]+' | tail -n 1 | tr -d '#' || true)

{
  echo "<!-- dockside:service=${SERVICE} -->"
  echo "<!-- dockside:sha=${SHA} -->"
  echo "<!-- dockside:pr=${PR} -->"
  echo "<!-- dockside:run=${RUN_URL} -->"
  echo "## Post-deploy smoke test failed in production"
  echo
  echo "| | |"
  echo "|---|---|"
  echo "| **Service** | \`${SERVICE}\` |"
  echo "| **Environment** | production |"
  echo "| **Commit** | \`${SHORT}\` ${SUBJECT} |"
  echo "| **Author** | ${AUTHOR} |"
  echo "| **Pipeline run** | ${RUN_URL} |"
  echo
  echo "### Smoke checks"
  cat smoke-report.md 2>/dev/null || echo "_no smoke report_"
  echo
  echo "### Service error log (last 20 lines)"
  echo '```'
  tail -n 20 server.log 2>/dev/null || true
  echo '```'
  echo
  echo "### Change under deploy"
  echo '```diff'
  git diff HEAD~1 HEAD -- src | head -n 60
  echo '```'
} > alert.md

gh issue create \
  --title "[ALERT] ${SERVICE}: post-deploy smoke test failed (${SHORT})" \
  --body-file alert.md \
  --label alert --label production
