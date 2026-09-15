#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  cat <<'EOF'
Usage: ./scripts/worktree-finish.sh [base-branch]

Closes out a lane: verifies the worktree is clean and not behind its base,
runs ./scripts/check.sh, pushes the branch, and opens (or reuses) a PR via
the GitHub CLI if available. Run from inside the lane's worktree.

  base-branch   Branch to compare and open the PR against (default: main)
EOF
  exit 0
fi

BASE_BRANCH="${1:-main}"

BRANCH="$(git branch --show-current)"
[ -n "$BRANCH" ] || die "not on a branch (detached HEAD?)"
[ "$BRANCH" != "$BASE_BRANCH" ] || die "refusing to finish the base branch itself ($BASE_BRANCH)"

[ -z "$(git status --porcelain)" ] || die "worktree is dirty; review and commit the intended files explicitly"

printf 'Fetching origin/%s...\n' "$BASE_BRANCH"
git fetch origin "$BASE_BRANCH"
git show-ref --verify --quiet "refs/remotes/origin/${BASE_BRANCH}" || die "origin/${BASE_BRANCH} is unavailable"
git merge-base --is-ancestor "origin/${BASE_BRANCH}" HEAD || die "branch has a stale base; rebase onto origin/${BASE_BRANCH} and rerun"
[ "$(git rev-list --count "origin/${BASE_BRANCH}..HEAD")" -gt 0 ] || die "branch contains no commits beyond origin/${BASE_BRANCH}"

./scripts/check.sh

git push --set-upstream origin "$BRANCH"

if ! command -v gh >/dev/null 2>&1; then
  printf 'gh CLI not found — push complete. Open a PR manually against %s.\n' "$BASE_BRANCH"
  exit 0
fi

if PR_URL="$(gh pr view "$BRANCH" --json url --jq .url 2>/dev/null)"; then
  printf 'Existing PR: %s\n' "$PR_URL"
else
  PR_URL="$(gh pr create --base "$BASE_BRANCH" --head "$BRANCH" --fill)"
  printf 'Created PR: %s\n' "$PR_URL"
fi

printf 'STOP: request review. Do not merge your own PR.\n'
