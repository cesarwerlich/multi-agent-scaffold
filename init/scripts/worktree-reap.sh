#!/usr/bin/env bash
# worktree-reap.sh — remove lane worktrees whose work is finished.
#
# Nothing removes a lane worktree after its PR merges, so they pile up, and
# agents read a leftover worktree as "work remains". This sweeps them.
#
# A worktree under .worktrees/ is reaped only when ALL of these hold:
#   - its branch has a MERGED PR and no OPEN PR (closed-unmerged is kept)
#   - it has no uncommitted or untracked changes
#   - it is not the worktree this script runs from
#   - nothing in it changed for --min-age-days (default 2): last commit and
#     the worktree's own creation both count
#
# Default is a dry run. Branch refs are never deleted. Ignored files (build
# output, a linked .env) go away with the worktree — the .env link only removes
# the pointer, never the real file.
#
# Usage: ./scripts/worktree-reap.sh [--apply] [--min-age-days N]
set -euo pipefail

APPLY=0
MIN_AGE_DAYS=2
while [ $# -gt 0 ]; do
  case "$1" in
    --apply) APPLY=1; shift ;;
    --min-age-days) MIN_AGE_DAYS="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,19p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done
case "$MIN_AGE_DAYS" in ''|*[!0-9]*) echo "--min-age-days must be a non-negative integer" >&2; exit 1 ;; esac

# Resolve the primary checkout even when run from inside a worktree.
CURRENT_TOP="$(git rev-parse --show-toplevel)"
COMMON_DIR="$(git rev-parse --git-common-dir)"
REPO_ROOT="$(cd "$COMMON_DIR/.." && pwd -P)"   # physical path, to match git worktree list
cd "$REPO_ROOT"

if ! command -v gh >/dev/null 2>&1; then
  echo "worktree-reap: gh not available; nothing reaped."
  exit 0
fi

# One line per PR: "<head branch> <STATE>".
PR_STATES="$(gh pr list --state all --limit 1000 --json headRefName,state \
  --jq '.[] | "\(.headRefName) \(.state)"' 2>/dev/null || true)"
if [ -z "$PR_STATES" ]; then
  echo "worktree-reap: no PR states readable; nothing reaped."
  exit 0
fi

if stat -c %Y / >/dev/null 2>&1; then
  mtime_of() { stat -c %Y "$1" 2>/dev/null || echo 0; }   # GNU
else
  mtime_of() { stat -f %m "$1" 2>/dev/null || echo 0; }   # BSD / macOS
fi

idle_days() {
  local wt="$1" latest created
  latest="$(git -C "$wt" log -1 --format=%ct HEAD 2>/dev/null || echo 0)"
  created="$(mtime_of "$wt/.git")"
  [ "$created" -gt "$latest" ] && latest="$created"
  echo $(( ( $(date +%s) - latest ) / 86400 ))
}

reaped=0
while IFS="$(printf '\t')" read -r wt ref; do
  [ -n "$wt" ] || continue
  case "$wt" in "$REPO_ROOT"/.worktrees/*) ;; *) continue ;; esac
  [ -d "$wt" ] || continue
  branch="${ref#refs/heads/}"

  case "$CURRENT_TOP" in "$wt"|"$wt"/*) echo "keep   $wt  (this script runs from it)"; continue ;; esac

  states="$(printf '%s\n' "$PR_STATES" | awk -v b="$branch" '$1 == b { print $2 }')"
  if printf '%s\n' "$states" | grep -qx "OPEN"; then echo "keep   $wt  (open PR: $branch)"; continue; fi
  if ! printf '%s\n' "$states" | grep -qx "MERGED"; then echo "keep   $wt  (no merged PR: $branch)"; continue; fi

  if [ -n "$(git -C "$wt" status --porcelain 2>/dev/null)" ]; then
    echo "keep   $wt  (uncommitted changes)"; continue
  fi

  age="$(idle_days "$wt")"
  if [ "$age" -lt "$MIN_AGE_DAYS" ]; then echo "keep   $wt  (active ${age}d ago)"; continue; fi

  if [ "$APPLY" -ne 1 ]; then
    echo "reap   $wt  ($branch, ${age}d idle)"
    reaped=$((reaped + 1)); continue
  fi
  if git worktree remove "$wt" >/dev/null 2>&1; then
    echo "reaped $wt"; reaped=$((reaped + 1))
  else
    echo "FAILED $wt  (left in place)"
  fi
done <<EOF_WORKTREES
$(git worktree list --porcelain | awk '/^worktree /{w=substr($0,10)} /^branch /{print w"\t"substr($0,8)}')
EOF_WORKTREES

if [ "$APPLY" -eq 1 ]; then
  git worktree prune
  echo "$reaped worktree(s) reaped."
else
  echo "$reaped worktree(s) would be reaped (dry run — pass --apply to remove)."
fi
