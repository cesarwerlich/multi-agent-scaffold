#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <target-dir> [project-name]" >&2
}

if [ "${1:-}" = "" ]; then
  usage
  exit 1
fi

target_dir="$1"
project_name="${2:-$(basename "$target_dir")}"
template_dir="$(cd "$(dirname "$0")/.." && pwd)"

readme_created=0
[ -e "$target_dir/README.md" ] || [ -L "$target_dir/README.md" ] || readme_created=1

mkdir -p "$target_dir"

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

# Only listed payload files are copied: tracked files in a Git checkout, or a
# filtered walk otherwise. See scripts/payload-files.sh.
list_payload() {
  "$template_dir/scripts/payload-files.sh" "$1" > "$2"
}

# copy_listed <list> <src-root> <dest-root> [top-level-item]
copy_listed() {
  while IFS= read -r -d '' rel; do
    if [ -n "${4:-}" ]; then
      case "$rel" in "$4"|"$4"/*) ;; *) continue ;; esac
    fi
    mkdir -p "$(dirname "$3/$rel")"
    cp -R "$2/$rel" "$3/$rel"
  done < "$1"
}

list_payload "$template_dir" "$work_dir/payload"
while IFS= read -r -d '' rel; do printf '%s\n' "${rel%%/*}"; done < "$work_dir/payload" |
  LC_ALL=C sort -u > "$work_dir/items"

while IFS= read -r item; do
  dest="$target_dir/$item"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "skip existing: $dest"
    continue
  fi
  copy_listed "$work_dir/payload" "$template_dir" "$target_dir" "$item"
  echo "created: $dest"
done < "$work_dir/items"

# The agent subsystem is single-sourced at the repo root (skills/, agents/,
# references/) and generated into the new repo's .agents/ here, so there is no
# committed duplicate to drift. If the sources are absent (e.g. running from a
# detached copy of init/), the optional subsystem is simply skipped.
agents_source_root="$(cd "$template_dir/.." && pwd)"
for sub in skills agents references; do
  src="$agents_source_root/$sub"
  dest="$target_dir/.agents/$sub"
  if [ ! -d "$src" ]; then
    echo "note: agent source missing, skipping .agents/$sub ($src)" >&2
    continue
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "skip existing: $dest"
    continue
  fi
  list_payload "$src" "$work_dir/$sub"
  mkdir -p "$dest"
  copy_listed "$work_dir/$sub" "$src" "$dest"
  echo "generated: $dest"
done

if [ "$readme_created" -eq 1 ] && grep -q '^# Project Name$' "$target_dir/README.md" 2>/dev/null; then
  tmp_file="$(mktemp)"
  sed "s/^# Project Name$/# ${project_name}/" "$target_dir/README.md" > "$tmp_file"
  mv "$tmp_file" "$target_dir/README.md"
fi


echo "Initialized $project_name at $target_dir"
