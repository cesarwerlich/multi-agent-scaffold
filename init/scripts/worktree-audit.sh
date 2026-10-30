#!/usr/bin/env bash
# Read-only: list registered worktrees and fail on any outside the allowed roots.
# Allowed: <repo>/.worktrees/* (lane script) and <repo>/.claude/worktrees/*
# (Claude Code). Add roots with WORKTREE_AUDIT_ALLOW (colon-separated paths).
# Agent tools (Codex, Antigravity, Claude) can create worktrees on their own,
# so the lane script alone cannot keep sibling folders out of the parent dir.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$(pwd -P)"
BASE="${1:-main}"
bad=0
path=""; branch=""; prunable=""
report() {
  [ -n "$path" ] || return 0
  [ "$path" = "$ROOT" ] && return 0
  ok=0
  case "$path/" in "$ROOT/.worktrees/"*|"$ROOT/.claude/worktrees/"*) ok=1 ;; esac
  IFS=: read -r -a extra <<< "${WORKTREE_AUDIT_ALLOW:-}"
  for r in ${extra[@]+"${extra[@]}"}; do
    [ -n "$r" ] && r="$(cd "$r" 2>/dev/null && pwd -P || printf '%s' "$r")" &&
      case "$path/" in "${r%/}/"*) ok=1 ;; esac
  done
  state="ok"
  [ "$ok" -eq 1 ] || { state="OUTSIDE allowed roots"; bad=1; }
  [ -z "$prunable" ] || state="$state, prunable (missing on disk)"
  merged=""
  if [ -n "$branch" ] && git show-ref --verify --quiet "refs/heads/$BASE" &&
    git merge-base --is-ancestor "refs/heads/$branch" "refs/heads/$BASE" 2>/dev/null; then
    merged=" merged-into-$BASE"
  fi
  printf '%s  [%s]%s  %s\n' "$path" "${branch:-detached}" "$merged" "$state"
}
while IFS= read -r line; do
  case "$line" in
    "worktree "*) report; path="${line#worktree }"; branch=""; prunable="" ;;
    "branch refs/heads/"*) branch="${line#branch refs/heads/}" ;;
    prunable*) prunable=1 ;;
  esac
done < <(git worktree list --porcelain; printf '\n')
report
[ "$bad" -eq 0 ] || { echo "ERROR: worktrees outside allowed roots; move them or run scripts/worktree-cleanup.sh" >&2; exit 1; }
