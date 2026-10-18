#!/usr/bin/env bash
# Read-only, repository-local retrieval; no arbitrary CLI passthrough.
set -euo pipefail
umask 077
repo="$(cd "$(dirname "$0")/.." && pwd -P)"
common="$(git -C "$repo" rev-parse --git-common-dir)"
case "$common" in /*) ;; *) common="$repo/$common" ;; esac
common="$(cd "$common" && pwd -P)"
state="$(dirname "$common")/.cache/reference-context"
fail() { echo "$*" >&2; exit 1; }
case "${1:-}" in
  project)
    [ "$#" -eq 2 ] || fail 'Usage: reference-search.sh project "query"'
    query="$2" ;;
  peer)
    [ "$#" -eq 3 ] || fail 'Usage: reference-search.sh peer <reviewed-corpus> "query"'
    [[ "$2" =~ ^[a-z][a-z0-9-]*$ ]] || fail 'Invalid corpus name'
    [ -f "$repo/docs/references/$2.json" ] || fail 'Add and review a pinned reference manifest first'
    corpus="$2"; query="$3" ;;
  *) fail 'Only explicit project or peer retrieval is supported' ;;
esac
[ -n "$query" ] && [[ "$query" != -* ]] || fail 'Query must be nonempty text, not CLI flags'
# Refuse local-state symlinks as well as global runtime fallbacks.
for rel in .cache .cache/reference-context .cache/reference-context/bin .cache/reference-context/bin/xerj .cache/reference-context/code .cache/reference-context/hub .cache/reference-context/port .cache/reference-context/data .cache/reference-context/data/admin.key; do
  [ ! -L "$(dirname "$common")/$rel" ] || fail 'Repository-local tool state must not contain symlinks'
done
binary="$state/bin/xerj"
[ -x "$binary" ] || fail 'Install a verified local binary; see docs/reference-context.md'
[ -r "$state/port" ] && [ -r "$state/data/admin.key" ] || fail 'Configure an authenticated local node first'
port="$(cat "$state/port")"
[[ "$port" =~ ^[1-9][0-9]{3,4}$ ]] || fail 'Invalid local port'
(( port >= 1024 && port <= 65533 )) || fail 'Port triplet out of range'
export XERJ_URL="http://127.0.0.1:$port"
export XERJ_CODE_HOME="$state/code" XERJ_HUB_HOME="$state/hub"
export XERJ_DISABLE_FEEDBACK=true
export XERJ_API_KEY="$(cat "$state/data/admin.key")"
export XERJ_AUTH="ApiKey $XERJ_API_KEY"
[ -n "$XERJ_API_KEY" ] || fail 'Empty local API key'
# Shared by this repository's worktrees, distinct across unrelated checkouts.
prefix="reference-$(printf '%s' "$state" | git hash-object --stdin | cut -c 1-12)"
if [ "$1" = project ]; then
  exec "$binary" search --url "$XERJ_URL" --prefix "$prefix" -k 3 --full 600 "$query"
fi
exec "$binary" code "$corpus" "$query" --url "$XERJ_URL" -k 3 --full 600
