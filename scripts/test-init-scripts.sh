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
echo "$passed passed, $failed failed"
[ "$failed" -eq 0 ]
