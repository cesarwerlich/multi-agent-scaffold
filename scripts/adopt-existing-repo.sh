#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage: adopt-existing-repo.sh [--profile minimal|github|full] [--report-only] [--with-evals-dir] <target-dir>

Profiles:
  minimal      Core docs and agent guidance only. Default.
  github       Minimal plus GitHub templates/workflows when missing.
  full         Copy every top-level payload item from init/ when missing.

Options:
  --report-only     Print what would happen without writing files.
  --with-evals-dir  Create evals/README.md when missing.
USAGE
}

profile="minimal"
report_only=0
with_evals_dir=0
target_dir=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --profile)
      profile="${2:-}"
      shift 2
      ;;
    --report-only)
      report_only=1
      shift
      ;;
    --with-evals-dir)
      with_evals_dir=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      target_dir="$1"
      shift
      ;;
  esac
done

case "$profile" in
  minimal|github|full) ;;
  *)
    echo "Invalid profile: $profile" >&2
    usage
    exit 1
    ;;
esac

if [ -z "$target_dir" ]; then
  usage
  exit 1
fi

template_dir="$(cd "$(dirname "$0")/../init" && pwd)"
target_dir="$(cd "$target_dir" 2>/dev/null && pwd || true)"

if [ -z "$target_dir" ] || [ ! -d "$target_dir" ]; then
  echo "Target directory does not exist: ${target_dir:-<missing>}" >&2
  exit 1
fi

created=()
skipped=()

copy_missing() {
  src_rel="$1"
  dest="$target_dir/$src_rel"
  src="$template_dir/$src_rel"

  if [ ! -e "$src" ]; then
    echo "Template item missing: $src_rel" >&2
    return
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    skipped+=("$src_rel")
    return
  fi

  created+=("$src_rel")
  if [ "$report_only" -eq 0 ]; then
    mkdir -p "$(dirname "$dest")"
    cp -R "$src" "$dest"
  fi
}

copy_minimal() {
  for item in \
    AGENTS.md \
    CLAUDE.md \
    ANTIGRAVITY.md \
    CONTEXT.md \
    TASKS.md \
    DECISIONS.md \
    PLAYBOOK.md \
    SECURITY.md \
    docs/memory.md \
    docs/roadmap.md \
    docs/testing.md \
    docs/evals.md \
    docs/operations.md \
    docs/agents/README.md \
    docs/agents/lane-protocol.md \
    docs/agents/issue-lane-template.md \
    docs/agents/worktree-bootstrap.md \
    docs/agents/review-checklist.md \
    docs/adr/0001-template.md \
    docs/runbooks/README.md \
    scripts/check.sh \
    scripts/bootstrap.sh \
    scripts/lane-update.mjs \
    scripts/worktree-bootstrap.sh \
    scripts/worktree-finish.sh \
    scripts/worktree-cleanup.sh
  do
    copy_missing "$item"
  done
}

copy_github() {
  copy_missing ".github/pull_request_template.md"
  copy_missing ".github/ISSUE_TEMPLATE/agent_lane.md"
  copy_missing ".github/ISSUE_TEMPLATE/bug_report.md"
  copy_missing ".github/ISSUE_TEMPLATE/task.md"
  copy_missing ".github/workflows/ci.yml"
  copy_missing ".github/workflows/security.yml"
}

copy_full() {
  find "$template_dir" -mindepth 1 -maxdepth 1 | sort | while IFS= read -r item; do
    copy_missing "$(basename "$item")"
  done
}

case "$profile" in
  minimal)
    copy_minimal
    ;;
  github)
    copy_minimal
    copy_github
    ;;
  full)
    copy_full
    ;;
esac

# The agent subsystem is single-sourced at the repo root and generated into
# .agents/ for the full profile (mirroring new-repo.sh), so there is no
# committed duplicate to drift.
if [ "$profile" = "full" ]; then
  agents_source_root="$(cd "$template_dir/.." && pwd)"
  for sub in skills agents references; do
    src="$agents_source_root/$sub"
    dest_rel=".agents/$sub"
    dest="$target_dir/$dest_rel"
    if [ ! -d "$src" ]; then
      continue
    fi
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      skipped+=("$dest_rel")
      continue
    fi
    created+=("$dest_rel")
    if [ "$report_only" -eq 0 ]; then
      mkdir -p "$target_dir/.agents"
      cp -R "$src" "$dest"
    fi
  done
fi

if [ "$with_evals_dir" -eq 1 ]; then
  evals_readme="$target_dir/evals/README.md"
  if [ -e "$evals_readme" ] || [ -L "$evals_readme" ]; then
    skipped+=("evals/README.md")
  else
    created+=("evals/README.md")
    if [ "$report_only" -eq 0 ]; then
      mkdir -p "$target_dir/evals"
      cat > "$evals_readme" <<'EOF'
# Evals

Use this folder for repeatable eval datasets, run logs, fixtures, and benchmark artifacts.

Keep the lightweight strategy in `../docs/evals.md`; store executable or data-backed eval assets here only when the repo needs them.
EOF
    fi
  fi
fi

report_rel="docs/template-adoption/$(date +%F)-repo-template-adoption.md"
report_path="$target_dir/$report_rel"

write_report() {
  {
    echo "# Repo Template Adoption"
    echo
    echo "Date: $(date +%F)"
    echo "Profile: \`$profile\`"
    echo "Report only: \`$report_only\`"
    echo "Template source: \`$template_dir\`"
    echo
    echo "## Created"
    echo
    if [ "${#created[@]}" -eq 0 ]; then
      echo "- None"
    else
      for item in "${created[@]}"; do
        echo "- \`$item\`"
      done
    fi
    echo
    echo "## Skipped Existing"
    echo
    if [ "${#skipped[@]}" -eq 0 ]; then
      echo "- None"
    else
      for item in "${skipped[@]}"; do
        echo "- \`$item\`"
      done
    fi
    echo
    echo "## Manual Follow-Up"
    echo
    echo "- Review skipped files and merge useful guidance manually."
    echo "- Keep existing project-specific structure and commands authoritative."
    echo "- Run the target repo checks after any manual merges."
  } > "$1"
}

if [ "$report_only" -eq 1 ]; then
  echo "Report-only adoption for $target_dir"
  echo "Profile: $profile"
  echo
  echo "Would create:"
  if [ "${#created[@]}" -eq 0 ]; then
    echo "  none"
  else
    printf '  %s\n' "${created[@]}"
  fi
  echo
  echo "Would skip existing:"
  if [ "${#skipped[@]}" -eq 0 ]; then
    echo "  none"
  else
    printf '  %s\n' "${skipped[@]}"
  fi
else
  mkdir -p "$(dirname "$report_path")"
  if [ -e "$report_path" ] || [ -L "$report_path" ]; then
    echo "Skipped existing adoption report: $report_rel"
  else
    write_report "$report_path"
  fi
  echo "Adopted repo-template profile '$profile' into $target_dir"
  echo "Report path (may be retained from an earlier run): $report_rel"
fi
