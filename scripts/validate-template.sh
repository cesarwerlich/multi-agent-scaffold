#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

failures=0

fail() {
  echo "FAIL: $*" >&2
  failures=$((failures + 1))
}

required_files=(
  "init/README.md"
  "init/CONTEXT.md"
  "init/AGENTS.md"
  "init/CLAUDE.md"
  "init/ANTIGRAVITY.md"
  "init/TASKS.md"
  "init/DECISIONS.md"
  "init/SECURITY.md"
  "init/SUPPORT.md"
  "init/CONTRIBUTING.md"
  "init/CODEOWNERS"
  "init/.gitignore"
  "init/.env.example"
  "init/CLAUDE.local.md.example"
  "init/.agents/README.md"
  "init/docs/roadmap.md"
  "init/docs/memory.md"
  "init/docs/journal.md"
  "init/docs/testing.md"
  "init/docs/evals.md"
  "init/docs/operations.md"
  "init/docs/release.md"
  "init/docs/agents/README.md"
  "init/docs/agents/lane-protocol.md"
  "init/docs/agents/issue-lane-template.md"
  "init/docs/agents/worktree-bootstrap.md"
  "init/docs/agents/review-checklist.md"
  "init/docs/history/README.md"
  "init/docs/specs/README.md"
  "init/docs/template-adoption/README.md"
  "init/.github/ISSUE_TEMPLATE/agent_lane.md"
  "init/scripts/check.sh"
  "init/scripts/new-repo.sh"
  "init/scripts/worktree-bootstrap.sh"
  "init/scripts/worktree-cleanup.sh"
  "init/PLAYBOOK.md"
  "scripts/adopt-existing-repo.sh"
)

for path in "${required_files[@]}"; do
  [ -f "$path" ] || fail "missing required payload file: $path"
done

if find . -name ".DS_Store" -print | grep -q .; then
  fail ".DS_Store files are present"
fi

if find . -type f \( -name ".env" -o -name "*.pem" -o -name "*.key" \) -print | grep -q .; then
  fail "secret-like files are present"
fi

conflict_markers="$(grep -rlE '^(<<<<<<<|=======|>>>>>>>)' --exclude-dir=.git . 2>/dev/null || true)"
if [ -n "$conflict_markers" ]; then
  echo "$conflict_markers" >&2
  fail "unresolved merge-conflict markers found"
fi

placeholder_output="$(mktemp)"
while IFS= read -r match; do
  case "$match" in
    *'${{'*|*'={{'*|*'No unresolved `{{...}}`'*|*'unresolved {{...}} placeholders found'*) continue ;;
  esac
  echo "$match" >>"$placeholder_output"
done < <(rg -n '\{\{[^}]+\}\}' . 2>/dev/null || true)
if [ -s "$placeholder_output" ]; then
  cat "$placeholder_output" >&2
  fail "unresolved {{...}} placeholders found"
fi
rm -f "$placeholder_output"

while IFS= read -r skill_file; do
  if ! awk 'BEGIN{front=0; name=0; desc=0} NR==1 && $0=="---"{front=1; next} front && /^name: /{name=1} front && /^description: /{desc=1} front && $0=="---"{exit !(name && desc)} END{if (!front) exit 1}' "$skill_file"; then
    fail "malformed skill frontmatter: $skill_file"
  fi
done < <(find skills -name SKILL.md -type f 2>/dev/null | sort)

while IFS= read -r md_file; do
  dir="$(dirname "$md_file")"
  while IFS= read -r link; do
    case "$link" in
      http://*|https://*|mailto:*|\#*|'') continue ;;
    esac
    clean_link="${link%%#*}"
    clean_link="${clean_link//%20/ }"
    if [ ! -e "$dir/$clean_link" ]; then
      fail "broken local markdown link in $md_file: $link"
    fi
  done < <(grep -Eo '\[[^]]+\]\([^)]+\)' "$md_file" | sed -E 's/^.*\(([^)]+)\)$/\1/' || true)
done < <(find . -name "*.md" -type f | sort)

if [ "$failures" -gt 0 ]; then
  echo "$failures validation failure(s)." >&2
  exit 1
fi

echo "Template validation passed."
