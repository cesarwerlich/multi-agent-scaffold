#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ "$#" -lt 2 ]; then
  echo "Usage: ./scripts/worktree-bootstrap.sh <issue-number> <slug> [base-branch]"
  echo "  AGENT_TOOL env var sets the branch prefix (default: agent)"
  echo "  Examples: AGENT_TOOL=claude, AGENT_TOOL=codex, AGENT_TOOL=copilot"
  exit 1
fi

ISSUE_NUMBER="$1"
SLUG="$2"
BASE_BRANCH="${3:-main}"
AGENT_TOOL="${AGENT_TOOL:-agent}"
BRANCH_NAME="${AGENT_TOOL}/issue-${ISSUE_NUMBER}-${SLUG}"
WORKTREE_PATH=".worktrees/${ISSUE_NUMBER}-${SLUG}"

mkdir -p .worktrees

if git show-ref --verify --quiet "refs/heads/${BRANCH_NAME}"; then
  git worktree add "${WORKTREE_PATH}" "${BRANCH_NAME}"
else
  git worktree add -b "${BRANCH_NAME}" "${WORKTREE_PATH}" "${BASE_BRANCH}"
fi

# Link, don't copy: every copy of .env is another place a secret can leak or go
# stale, and finished worktrees are easy to forget. One real file, N pointers.
if [ -f ".env" ] && [ ! -e "${WORKTREE_PATH}/.env" ]; then
  ln -s "$(pwd)/.env" "${WORKTREE_PATH}/.env"
fi

cat <<EOF
Created worktree:
  branch:   ${BRANCH_NAME}
  worktree: ${WORKTREE_PATH}

Recommended next steps:
  cd ${WORKTREE_PATH}
  ./scripts/bootstrap.sh
  ./scripts/check.sh
EOF
