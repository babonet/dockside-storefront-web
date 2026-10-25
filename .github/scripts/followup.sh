#!/usr/bin/env bash
set -euo pipefail

printf '%s\n\n---\n_Opened automatically by Port from the postmortem of incident `%s`._\n' "$BODY" "$INCIDENT" > followup.md
ISSUE_URL=$(gh issue create --title "$TITLE" --body-file followup.md --label incident-followup)
echo "Follow-up issue: ${ISSUE_URL}" >> "$GITHUB_STEP_SUMMARY"

if [ "${ASSIGN}" != "true" ] || [ -z "${COPILOT_TOKEN}" ]; then
  echo "Copilot assignment skipped (disabled or no COPILOT_ASSIGN_TOKEN secret)" >> "$GITHUB_STEP_SUMMARY"
  exit 0
fi

# Assigning the Copilot coding agent requires a user token, not GITHUB_TOKEN.
NUMBER=${ISSUE_URL##*/}
GH_TOKEN="$COPILOT_TOKEN" gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      issue(number: $number) { id }
      suggestedActors(capabilities: [CAN_BE_ASSIGNED], first: 20) {
        nodes { login ... on Bot { id } ... on User { id } }
      }
    }
  }' -f owner="${GITHUB_REPOSITORY%/*}" -f repo="${GITHUB_REPOSITORY#*/}" -F number="$NUMBER" > ids.json

ISSUE_ID=$(jq -r '.data.repository.issue.id' ids.json)
BOT_ID=$(jq -r '.data.repository.suggestedActors.nodes[] | select(.login == "copilot-swe-agent") | .id' ids.json)

if [ -z "$BOT_ID" ]; then
  echo "Copilot coding agent is not assignable on this repository" >> "$GITHUB_STEP_SUMMARY"
  exit 0
fi

GH_TOKEN="$COPILOT_TOKEN" gh api graphql -f query='
  mutation($issue: ID!, $bot: ID!) {
    replaceActorsForAssignable(input: { assignableId: $issue, actorIds: [$bot] }) {
      assignable { ... on Issue { number } }
    }
  }' -f issue="$ISSUE_ID" -f bot="$BOT_ID" > /dev/null

echo "Assigned to the GitHub Copilot coding agent" >> "$GITHUB_STEP_SUMMARY"
