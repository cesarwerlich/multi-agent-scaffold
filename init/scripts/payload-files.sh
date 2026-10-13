#!/usr/bin/env bash
# Print the copyable files under a template directory as NUL-terminated paths
# relative to it. In a Git checkout only tracked files are listed, so local
# worktrees, ignored secrets and scratch output never reach a generated repo.
# A plain (non-Git) copy falls back to a filtered walk. Both modes also drop
# Git metadata, lane worktrees and secret-like names as a second guard.
set -euo pipefail

[ "$#" -eq 1 ] || { echo "Usage: $0 <template-dir>" >&2; exit 1; }
cd "$1"

excluded() {
  case "/$1/" in
    */.git/*|*/.worktrees/*|*/node_modules/*) return 0 ;;
  esac
  case "${1##*/}" in
    .env.example) return 1 ;;
    .git|.env|.env.*|*.pem|*.key|*.p12|*.crt|*.cert|id_rsa*|id_ed25519*) return 0 ;;
    .DS_Store|Thumbs.db|*.log|CLAUDE.local.md|settings.local.json) return 0 ;;
  esac
  return 1
}

emit() {
  while IFS= read -r -d '' path; do
    path="${path#./}"
    excluded "$path" && continue
    # Tracked gitlinks (submodules) appear as directories; never copy them.
    { [ -f "$path" ] || [ -L "$path" ]; } || continue
    printf '%s\0' "$path"
  done
}

if git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
  git ls-files --error-unmatch . >/dev/null 2>&1; then
  git ls-files -z -- . | emit
else
  find . \( -name .git -o -name .worktrees -o -name node_modules \) -prune -o \
    \( -type f -o -type l \) -print0 | emit
fi
