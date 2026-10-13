#!/usr/bin/env bash
# Fail when an instruction file names a repo path in backticks that does not
# exist. Agents follow these paths literally, so a stale one sends them to a
# file that is not there. Usage: check-doc-paths.sh <base-dir> <doc>...
# Docs are relative to <base-dir>; paths in them resolve against it too.
# A token counts as a path when it ends in "/" or a known file extension.
set -euo pipefail

[ "$#" -ge 2 ] || { echo "Usage: $0 <base-dir> <doc>..." >&2; exit 2; }
base="$1"
shift

# Optional or generated paths that may legitimately be absent.
optional_path() {
  case "$1" in
    CLAUDE.local.md|.agents/skills/|.agents/agents/|.agents/references/) return 0 ;;
  esac
  return 1
}

looks_like_path() {
  case "$1" in
    ''|/*|~*|-*|*' '*|*'<'*|*'>'*|*'{'*|*'$'*|*'*'*|*:*) return 1 ;;
    */|*.md|*.sh|*.mjs|*.js|*.json|*.yml|*.yaml|*.toml) return 0 ;;
  esac
  return 1
}

failures=0
for doc in "$@"; do
  [ -f "$base/$doc" ] || continue
  while IFS= read -r token; do
    token="${token#\`}"
    token="${token%\`}"
    token="${token#@}"
    token="${token#./}"
    looks_like_path "$token" || continue
    optional_path "$token" && continue
    if [ ! -e "$base/$token" ]; then
      echo "FAIL: $doc names missing path: $token" >&2
      failures=$((failures + 1))
    fi
  done < <(grep -o '`[^`]*`' "$base/$doc" || true)
done

[ "$failures" -eq 0 ]
