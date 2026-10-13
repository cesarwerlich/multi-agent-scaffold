#!/usr/bin/env bash
# Hermetic integration contracts: no network, agent invocation or secrets.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
fail() { echo "FAIL: $*" >&2; exit 1; }
reject() { if "$@" >"$fixture/rejected.log" 2>&1; then fail "unexpected success: $*"; fi; }
"$root/init/scripts/new-repo.sh" "$fixture/generated" Test > /dev/null
cd "$fixture/generated"
./scripts/bootstrap.sh
./scripts/check.sh
git init -q -b main
git config user.name 'Harness Fixture'
git config user.email 'fixture@example.invalid'
git add .
git commit -qm baseline
printf 'fixture-only\n' > .env
AGENT_TOOL=codex ./scripts/worktree-bootstrap.sh 6 safety > /dev/null
lane="$PWD/.worktrees/6-safety"
[ ! -e "$lane/.env" ] || fail 'secret copied'
printf 'interrupted work\n' > "$lane/pending.txt"
AGENT_TOOL=codex ./scripts/worktree-bootstrap.sh 6 safety > /dev/null
[ -f "$lane/pending.txt" ] || fail 'resume lost work'
reject ./scripts/worktree-cleanup.sh 6-safety
rm "$lane/pending.txt"
printf 'private artifact\n' > "$lane/.env"
reject ./scripts/worktree-cleanup.sh 6-safety
rm "$lane/.env"
printf 'lane change\n' > "$lane/change.txt"
git -C "$lane" add change.txt
git -C "$lane" commit -qm change
reject ./scripts/worktree-cleanup.sh 6-safety
git merge -q --ff-only codex/issue-6-safety
./scripts/worktree-cleanup.sh 6-safety
[ ! -d "$lane" ] || fail 'merged clean lane retained'
git show-ref --verify --quiet refs/heads/codex/issue-6-safety || fail 'branch deleted'
AGENT_TOOL=codex ./scripts/worktree-bootstrap.sh 6 safety > /dev/null
AGENT_TOOL=claude reject ./scripts/worktree-bootstrap.sh 6 safety
reject ./scripts/worktree-bootstrap.sh ../bad safety
reject ./scripts/worktree-bootstrap.sh 7 ../escape
reject ./scripts/worktree-cleanup.sh ../outside
mv "$lane" "$fixture/interrupted"
AGENT_TOOL=codex reject ./scripts/worktree-bootstrap.sh 6 safety
mv "$fixture/interrupted" "$lane"
# Repeated generation must not customize an existing README, even with template heading.
printf '# Project Name\nowner content\n' > README.md
cp README.md "$fixture/readme"
"$root/init/scripts/new-repo.sh" "$PWD" Different > /dev/null
cmp README.md "$fixture/readme" || fail 'generation overwrote README'
for profile in minimal github full; do
  target="$fixture/$profile"
  mkdir -p "$target"
  printf 'owner contract\n' > "$target/AGENTS.md"
  "$root/scripts/adopt-existing-repo.sh" --profile "$profile" --report-only "$target" > /dev/null
  [ "$(find "$target" -type f | wc -l | tr -d ' ')" = 1 ] || fail 'report-only wrote files'
  "$root/scripts/adopt-existing-repo.sh" --profile "$profile" "$target" > /dev/null
  [ "$(cat "$target/AGENTS.md")" = 'owner contract' ] || fail 'adoption overwrote contract'
  [ -x "$target/scripts/worktree-finish.sh" ] || fail 'missing finish helper'
  report="$target/docs/template-adoption/$(date +%F)-repo-template-adoption.md"
  printf 'owner report\n' > "$report"
  printf 'owner check\n' > "$target/scripts/check.sh"
  chmod -x "$target/scripts/check.sh"
  "$root/scripts/adopt-existing-repo.sh" --profile "$profile" "$target" > /dev/null
  [ "$(cat "$target/scripts/check.sh")" = 'owner check' ] || fail 'repeat adoption overwrote check'
  [ "$(cat "$report")" = 'owner report' ] || fail 'repeat adoption overwrote report'
  [ ! -x "$target/scripts/check.sh" ] || fail 'adoption changed owner mode'
done
mkdir "$fixture/symlink-adopt" "$fixture/symlink-new"
ln -s "$fixture/absent-adopt" "$fixture/symlink-adopt/AGENTS.md"
ln -s "$fixture/absent-new" "$fixture/symlink-new/README.md"
"$root/scripts/adopt-existing-repo.sh" "$fixture/symlink-adopt" > /dev/null
"$root/init/scripts/new-repo.sh" "$fixture/symlink-new" Test > /dev/null
[ ! -e "$fixture/absent-adopt" ] || fail 'adoption followed dangling destination'
[ ! -e "$fixture/absent-new" ] || fail 'generation followed dangling destination'
echo 'Harness integration contracts passed.'
