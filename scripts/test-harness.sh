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
AGENT_TOOL=codex ./scripts/worktree-bootstrap.sh 6 safety > "$fixture/resume.log"
grep -q 'Resumed worktree:' "$fixture/resume.log" || fail 'misleading resume banner'
grep -q 'dirty (changes preserved)' "$fixture/resume.log" || fail 'missing dirty resume status'
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
# A same-named tag at the base must not conceal unmerged lane commits.
git tag codex/issue-6-safety main
reject ./scripts/worktree-cleanup.sh 6-safety
[ -d "$lane" ] || fail 'tag bypassed unmerged branch guard'
git tag -d codex/issue-6-safety > /dev/null
# A base-name tag at the lane head must not replace the real base either.
git tag main refs/heads/codex/issue-6-safety
reject ./scripts/worktree-cleanup.sh 6-safety
git tag -d main > /dev/null
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
reject ./scripts/worktree-cleanup.sh 6-safety
grep -q 'git worktree list' "$fixture/rejected.log" || fail 'missing cleanup recovery hint'
mv "$fixture/interrupted" "$lane"
# Clean merged lanes remain protected by native Git locks.
git worktree lock "$lane" --reason 'fixture active lane'
reject ./scripts/worktree-cleanup.sh .worktrees/6-safety
[ -d "$lane" ] || fail 'locked worktree removed'
git worktree unlock "$lane"
./scripts/worktree-cleanup.sh .worktrees/6-safety > /dev/null
# Safe legacy names retain exact case and underscores on resume and cleanup.
# Simulate a lane created by an older helper, before identifier validation.
git worktree add -q -b Legacy_Tool/issue-9-Legacy_Lane .worktrees/9-Legacy_Lane main
AGENT_TOOL=Legacy_Tool ./scripts/worktree-bootstrap.sh 9 Legacy_Lane > "$fixture/legacy.log"
grep -q 'Resumed worktree:' "$fixture/legacy.log" || fail 'legacy resume rejected'
./scripts/worktree-cleanup.sh 9-Legacy_Lane > /dev/null
# Custom local bases work; a missing local base fails closed.
git branch integration
./scripts/worktree-bootstrap.sh 10 custom integration > /dev/null
reject ./scripts/worktree-cleanup.sh 10-custom absent-base
./scripts/worktree-cleanup.sh 10-custom integration > /dev/null
# Squash equivalence alone cannot authorize automatic cleanup.
./scripts/worktree-bootstrap.sh 11 squash > /dev/null
squash="$PWD/.worktrees/11-squash"
printf 'squash fixture\n' > "$squash/squash.txt"
git -C "$squash" add squash.txt
git -C "$squash" commit -qm 'lane squash change'
git merge -q --squash refs/heads/agent/issue-11-squash
git commit -qm 'squashed lane'
reject ./scripts/worktree-cleanup.sh 11-squash
[ -d "$squash" ] || fail 'squash-merged lane removed'
grep -q 'squash merge manually' "$fixture/rejected.log" || fail 'missing squash recovery hint'
# Detached HEAD and symlinked paths must not authorize removal.
./scripts/worktree-bootstrap.sh 12 detached > /dev/null
git -C .worktrees/12-detached checkout -q --detach
reject ./scripts/worktree-cleanup.sh 12-detached
ln -s "$squash" .worktrees/13-symlink
reject ./scripts/worktree-cleanup.sh 13-symlink
# A lane branch checked out in the primary tree is never relocated.
git branch agent/issue-14-primary
git checkout -q agent/issue-14-primary
reject ./scripts/worktree-bootstrap.sh 14 primary
git checkout -q main
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
# Issue #11: generation and full adoption copy only the tracked payload, never
# a maintainer's local worktrees, ignored secrets or scratch files.
tpl="$fixture/template"
mkdir "$tpl"
(cd "$root" && git ls-files -z --cached --others --exclude-standard) |
  while IFS= read -r -d '' rel; do
    [ -e "$root/$rel" ] || [ -L "$root/$rel" ] || continue
    mkdir -p "$(dirname "$tpl/$rel")"
    cp -R "$root/$rel" "$tpl/$rel"
  done
git -C "$tpl" init -q -b main
git -C "$tpl" add -A
git -C "$tpl" -c user.name='Harness Fixture' -c user.email='fixture@example.invalid' commit -qm template
git -C "$tpl" worktree add -q -b agent/issue-9-stale init/.worktrees/9-stale
plant() { mkdir -p "$(dirname "$1")"; printf 'contaminant\n' > "$1"; }
for junk in init/.env init/.DS_Store init/scratch.tmp init/docs/notes.local.md \
  init/scripts/debug.log skills/.DS_Store skills/draft-skill/SKILL.md agents/private.md; do
  plant "$tpl/$junk"
done
git -C "$tpl/init" ls-files | LC_ALL=C sort > "$fixture/expected-init"
git -C "$tpl/skills" ls-files | LC_ALL=C sort > "$fixture/expected-skills"
listing() { (cd "$1" && find . \( -type f -o -type l \) | sed 's|^\./||' | LC_ALL=C sort); }
assert_clean() {
  [ ! -e "$1/.worktrees" ] || fail "$2 copied a worktree"
  [ ! -e "$1/.env" ] || fail "$2 copied an ignored secret"
  if grep -rl '^gitdir:' "$1" 2>/dev/null | grep -q .; then fail "$2 copied a gitdir pointer"; fi
  if grep -rl 'contaminant' "$1" 2>/dev/null | grep -q .; then fail "$2 copied untracked files"; fi
  [ -f "$1/.env.example" ] || fail "$2 dropped .env.example"
}
"$tpl/init/scripts/new-repo.sh" "$fixture/clean-new" Clean > /dev/null
assert_clean "$fixture/clean-new" generation
listing "$fixture/clean-new" | grep -v '^\.agents/[sar]' > "$fixture/actual-init" || true
cmp -s "$fixture/expected-init" "$fixture/actual-init" || fail 'generation differs from tracked payload'
listing "$fixture/clean-new/.agents/skills" > "$fixture/actual-skills"
cmp -s "$fixture/expected-skills" "$fixture/actual-skills" || fail 'generated skills differ from tracked skills'
[ -x "$fixture/clean-new/scripts/worktree-finish.sh" ] || fail 'generation lost executable mode'
mkdir "$fixture/clean-adopt"
printf 'owner contract\n' > "$fixture/clean-adopt/AGENTS.md"
"$tpl/scripts/adopt-existing-repo.sh" --profile full "$fixture/clean-adopt" > /dev/null
assert_clean "$fixture/clean-adopt" 'full adoption'
[ "$(cat "$fixture/clean-adopt/AGENTS.md")" = 'owner contract' ] || fail 'full adoption overwrote contract'
adopt_report="$fixture/clean-adopt/docs/template-adoption/$(date +%F)-repo-template-adoption.md"
grep -q '^- `AGENTS.md`$' "$adopt_report" || fail 'full adoption report lost skipped items'
grep -q '^- `scripts`$' "$adopt_report" || fail 'full adoption report lost created items'
# A plain copy without Git metadata falls back to a filtered walk.
plain="$fixture/plain-template"
cp -R "$tpl" "$plain"
rm -rf "$plain/.git"
[ -f "$plain/init/.worktrees/9-stale/.git" ] || fail 'fixture lost the stale worktree'
"$plain/init/scripts/new-repo.sh" "$fixture/plain-new" Plain > /dev/null
[ ! -e "$fixture/plain-new/.worktrees" ] || fail 'fallback copied a worktree'
[ ! -e "$fixture/plain-new/.env" ] || fail 'fallback copied an ignored secret'
[ ! -e "$fixture/plain-new/.DS_Store" ] || fail 'fallback copied OS metadata'
[ ! -e "$fixture/plain-new/scripts/debug.log" ] || fail 'fallback copied a log'
[ -f "$fixture/plain-new/.env.example" ] || fail 'fallback dropped .env.example'
echo 'Harness integration contracts passed.'
