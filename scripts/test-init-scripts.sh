#!/usr/bin/env bash
# Behavioral tests for the scripts shipped in init/scripts/. Each test builds a
# throwaway project from the template, so nothing touches this checkout.
set -euo pipefail

cd "$(dirname "$0")/.."
TEMPLATE_ROOT="$(pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

passed=0
failed=0

pass() { passed=$((passed + 1)); echo "  ok   $*"; }
fail() { failed=$((failed + 1)); echo "  FAIL $*" >&2; }

# Builds a committed project at $1 on branch main.
new_project() {
  local dir="$1"
  "$TEMPLATE_ROOT/init/scripts/new-repo.sh" "$dir" "Test Project" >/dev/null
  (
    cd "$dir"
    git init -q
    git checkout -q -b main
    git config user.email "test@users.noreply.github.com"
    git config user.name "Test"
    git add -A
    git commit -q -m "init"
  )
}

echo "worktree-bootstrap.sh"

p="$WORK/bootstrap"
new_project "$p"
echo "SECRET=primary" >"$p/.env"
(cd "$p" && AGENT_TOOL=t ./scripts/worktree-bootstrap.sh 1 demo >/dev/null)
if [ -L "$p/.worktrees/1-demo/.env" ]; then
  pass "links .env instead of copying it"
else
  fail "expected .worktrees/1-demo/.env to be a symlink to the primary .env"
fi

echo
echo "scan-secrets.sh"

p="$WORK/scan"
new_project "$p"

scan() { (cd "$p" && ./scripts/scan-secrets.sh 2>&1); }

if scan >/dev/null; then pass "clean project passes"; else fail "clean project should pass"; fi

# Fixtures are assembled at runtime so this file never contains a real-looking token.
jwt="eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ0ZXN0In0.c2lnbmF0dXJl"
printf 'const token = "%s";\n' "$jwt" >"$p/app.ts"
if out="$(scan)"; then
  fail "JWT literal in a source file should fail"
elif printf '%s' "$out" | grep -q 'app.ts'; then
  pass "flags a JWT literal and names the file"
else
  fail "JWT failure should name app.ts, got: $out"
fi

printf 'app.ts\n' >"$p/.secret-scan-ignore"
if scan >/dev/null; then pass "honors .secret-scan-ignore"; else fail ".secret-scan-ignore should allow app.ts"; fi
rm "$p/.secret-scan-ignore" "$p/app.ts"

printf 'COOKIE = "a=1; b=2; c=3; sessionid=abcdef123456"\n' >"$p/fetch.py"
if out="$(scan)"; then
  fail "cookie-jar literal should fail"
elif printf '%s' "$out" | grep -q 'fetch.py'; then
  pass "flags a cookie-jar literal"
else
  fail "cookie-jar failure should name fetch.py, got: $out"
fi

printf 'COLORS = "a=1; b=2; c=3; d=4"\n' >"$p/fetch.py"
if scan >/dev/null; then pass "key=value pairs without a session key pass"; else fail "plain key=value pairs should not be flagged"; fi

echo
echo "worktree-reap.sh"

p="$WORK/reap"
new_project "$p"

# Fake gh: `gh pr list ...` prints "<branch> <STATE>" lines from $FAKE_GH_STATES.
mkdir -p "$WORK/bin"
cat >"$WORK/bin/gh" <<'EOF'
#!/usr/bin/env bash
[ "$1 $2" = "pr list" ] && cat "$FAKE_GH_STATES"
exit 0
EOF
chmod +x "$WORK/bin/gh"
export FAKE_GH_STATES="$WORK/pr-states"

# make_lane <issue> <slug> <PR state or none> <old|fresh> <clean|dirty>
make_lane() {
  local issue="$1" slug="$2" state="$3" age="$4" dirt="$5"
  local branch="t/issue-${issue}-${slug}" wt="$p/.worktrees/${issue}-${slug}"
  (cd "$p" && AGENT_TOOL=t ./scripts/worktree-bootstrap.sh "$issue" "$slug" >/dev/null 2>&1)
  if [ "$age" = "old" ]; then
    (
      cd "$wt"
      echo work >"work-$issue.txt"
      git add .
      GIT_AUTHOR_DATE="2020-01-01T00:00:00" GIT_COMMITTER_DATE="2020-01-01T00:00:00" git commit -q -m "old work"
      touch -t 202001010000 .git
    )
  fi
  if [ "$dirt" = "dirty" ]; then
    echo scratch >"$wt/uncommitted.txt"
    touch -t 202001010000 "$wt/uncommitted.txt"
  fi
  if [ "$state" != "none" ]; then echo "$branch $state" >>"$FAKE_GH_STATES"; fi
}

: >"$FAKE_GH_STATES"
make_lane 1 merged MERGED old clean
make_lane 2 open OPEN old clean
make_lane 3 nopr none old clean
make_lane 4 dirty MERGED old dirty
make_lane 5 fresh MERGED fresh clean
make_lane 6 closed CLOSED old clean

reap() { (cd "$p" && PATH="$WORK/bin:$PATH" ./scripts/worktree-reap.sh "$@" 2>&1); }

out="$(reap)"
if [ -d "$p/.worktrees/1-merged" ]; then pass "dry run removes nothing"; else fail "dry run must not remove worktrees"; fi
if printf '%s' "$out" | grep -q 'reap .*1-merged'; then pass "dry run reports the merged lane"; else fail "dry run should list 1-merged, got: $out"; fi

reap --apply >/dev/null
if [ ! -d "$p/.worktrees/1-merged" ]; then pass "removes a clean, old, merged lane"; else fail "1-merged should be removed"; fi
if git -C "$p" show-ref --verify --quiet refs/heads/t/issue-1-merged; then pass "never deletes the branch"; else fail "branch t/issue-1-merged must survive"; fi
if [ -d "$p/.worktrees/2-open" ]; then pass "keeps a lane with an open PR"; else fail "2-open should be kept"; fi
if [ -d "$p/.worktrees/3-nopr" ]; then pass "keeps a lane with no PR"; else fail "3-nopr should be kept"; fi
if [ -d "$p/.worktrees/4-dirty" ]; then pass "keeps a lane with uncommitted work"; else fail "4-dirty should be kept"; fi
if [ -d "$p/.worktrees/5-fresh" ]; then pass "keeps a lane active within the age window"; else fail "5-fresh should be kept"; fi
if [ -d "$p/.worktrees/6-closed" ]; then pass "keeps a lane whose PR was closed unmerged"; else fail "6-closed should be kept"; fi

reap --apply --min-age-days 0 >/dev/null
if [ ! -d "$p/.worktrees/5-fresh" ]; then pass "--min-age-days 0 reaps the fresh merged lane"; else fail "5-fresh should go with --min-age-days 0"; fi
if [ -d "$p/.worktrees/4-dirty" ]; then pass "dirty lane still kept at --min-age-days 0"; else fail "4-dirty must survive regardless of age"; fi

make_lane 7 inside MERGED old clean
out="$(cd "$p/.worktrees/7-inside" && PATH="$WORK/bin:$PATH" ../../scripts/worktree-reap.sh --apply 2>&1 || true)"
if [ -d "$p/.worktrees/7-inside" ] && printf '%s' "$out" | grep -q 'this script runs from it'; then
  pass "never reaps the worktree it runs from"
else
  fail "7-inside must be kept with an explicit reason, got: $out"
fi

echo
echo "$passed passed, $failed failed"
[ "$failed" -eq 0 ]
