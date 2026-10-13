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

copy_missing() {
  src="$1"
  dest="$2"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "skip existing: $dest"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  cp -R "$src" "$dest"
  echo "created: $dest"
}

find "$template_dir" -mindepth 1 -maxdepth 1 | while IFS= read -r item; do
  base="$(basename "$item")"
  copy_missing "$item" "$target_dir/$base"
done

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
  mkdir -p "$target_dir/.agents"
  cp -R "$src" "$dest"
  echo "generated: $dest"
done

if [ "$readme_created" -eq 1 ] && grep -q '^# Project Name$' "$target_dir/README.md" 2>/dev/null; then
  tmp_file="$(mktemp)"
  sed "s/^# Project Name$/# ${project_name}/" "$target_dir/README.md" > "$tmp_file"
  mv "$tmp_file" "$target_dir/README.md"
fi


echo "Initialized $project_name at $target_dir"
