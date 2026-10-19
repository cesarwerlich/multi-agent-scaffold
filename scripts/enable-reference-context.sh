#!/usr/bin/env bash
# Explicit optional adoption. Never called by new-repo/adopt/bootstrap/check.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
[ "$#" -eq 1 ] || { echo "Usage: $0 <repository-root>" >&2; exit 1; }
target="$(cd "$1" && pwd -P)"
[ "$(git -C "$target" rev-parse --show-toplevel)" = "$target" ] || {
  echo 'Target must be a Git checkout root' >&2; exit 1;
}
# Check the state root and real sensitive destinations, not an ignorable probe.
for sensitive in .cache/reference-context/ .cache/reference-context/data/ \
  .cache/reference-context/data/admin.key .cache/reference-context/bin/xerj \
  .cache/reference-context/port .cache/reference-context/node.pid \
  .cache/reference-context/node.log .cache/reference-context/code/ \
  .cache/reference-context/hub/; do
  git -C "$target" check-ignore -q "$sensitive" || {
    echo "Ignore repository-local state before enabling: $sensitive" >&2; exit 1;
  }
done
[ -z "$(git -C "$target" ls-files -- .cache/reference-context)" ] || {
  echo 'Tracked local tool state must be removed from the index before enabling' >&2; exit 1;
}
files=(scripts/reference-search.sh docs/reference-context.md docs/references/README.md .codex/config.toml .xerjignore)
# Preflight every destination before copying anything, including parent links.
for rel in "${files[@]}"; do
  parent="$rel"
  while [ "$parent" != . ]; do
    [ ! -L "$target/$parent" ] || { echo "Refusing symlink: $parent" >&2; exit 1; }
    if [ "$parent" != "$rel" ] && [ -e "$target/$parent" ] && [ ! -d "$target/$parent" ]; then
      echo "Parent is not a directory: $parent" >&2; exit 1
    fi
    parent="$(dirname "$parent")"
  done
  [ ! -e "$target/$rel" ] || { echo "Existing file; integrate manually: $rel" >&2; exit 1; }
done
for rel in "${files[@]}"; do
  mkdir -p "$(dirname "$target/$rel")"
  cp "$root/optional/reference-context/$rel" "$target/$rel"
done
echo 'Added optional reference context. Review docs/reference-context.md before installing tools.'
