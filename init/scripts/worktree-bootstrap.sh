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

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
[[ "$ISSUE_NUMBER" =~ ^[1-9][0-9]*$ ]] || die "issue must be a positive integer"
[[ "$SLUG" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || die "slug must be lowercase kebab-case"
[[ "$AGENT_TOOL" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || die "tool must be lowercase kebab-case"
git check-ref-format --branch "$BASE_BRANCH" >/dev/null || die "invalid base branch"
ROOT="$(pwd -P)"
EXPECTED="$ROOT/$WORKTREE_PATH"
REGISTERED="$(git worktree list --porcelain | awk -v branch="refs/heads/$BRANCH_NAME" '
  /^worktree / { path=substr($0,10) }
  $1 == "branch" && $2 == branch { print path }
')"
if [ -n "$REGISTERED" ]; then
  [ "$REGISTERED" = "$EXPECTED" ] || die "branch registered elsewhere: $REGISTERED"
  [ -d "$EXPECTED" ] || die "registered path missing; inspect git worktree list before recovery"
  [ "$(git -C "$EXPECTED" rev-parse --show-toplevel)" = "$EXPECTED" ] || die "invalid registered worktree"
  [ "$(git -C "$EXPECTED" branch --show-current)" = "$BRANCH_NAME" ] || die "worktree branch mismatch"
  echo "Reusing registered worktree."
elif [ -e "$WORKTREE_PATH" ] || [ -L "$WORKTREE_PATH" ]; then
  die "path exists but is not this registered lane: $WORKTREE_PATH"
else
  mkdir -p .worktrees
  if git show-ref --verify --quiet "refs/heads/${BRANCH_NAME}"; then
    git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"
  else
    git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" "$BASE_BRANCH"
  fi
fi
# Never propagate .env or credentials. Configure only necessary local secrets explicitly.

cat <<EOF
Created worktree:
  branch:   ${BRANCH_NAME}
  worktree: ${WORKTREE_PATH}

Recommended next steps:
  cd ${WORKTREE_PATH}
  ./scripts/bootstrap.sh
  ./scripts/check.sh
EOF
