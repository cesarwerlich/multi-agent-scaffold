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
echo "$passed passed, $failed failed"
[ "$failed" -eq 0 ]
