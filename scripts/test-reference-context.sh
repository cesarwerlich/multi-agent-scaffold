#!/usr/bin/env bash
# Offline integration: no downloads, server startup or external writes.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
fixture="$(mktemp -d)"
fixture="$(cd "$fixture" && pwd -P)"
trap 'rm -rf "$fixture"' EXIT
fail() { echo "FAIL: $*" >&2; exit 1; }
reject() { if "$@" > "$fixture/rejected.log" 2>&1; then fail "unexpected success: $*"; fi; }
"$root/init/scripts/new-repo.sh" "$fixture/generated project" Reference > /dev/null
[ ! -e "$fixture/generated/scripts/reference-search.sh" ] || fail 'enabled by default'
git -C "$fixture/generated project" init -q
"$root/scripts/enable-reference-context.sh" "$fixture/generated project" > /dev/null
repo="$fixture/generated project"
[ -f "$repo/.codex/config.toml" ] || fail 'AgentMemory override absent'
grep -q 'enabled = false' "$repo/.codex/config.toml" || fail 'AgentMemory enabled'
reject "$root/scripts/enable-reference-context.sh" "$repo"
reject "$repo/scripts/reference-search.sh" project 'example'
mkdir -p "$fixture/conflict/.codex"
printf 'preserve\n' > "$fixture/conflict/.codex/config.toml"
git -C "$fixture/conflict" init -q
printf '.cache/\n' > "$fixture/conflict/.gitignore"
reject "$root/scripts/enable-reference-context.sh" "$fixture/conflict"
[ ! -e "$fixture/conflict/scripts/reference-search.sh" ] || fail 'partial conflict install'
grep -q preserve "$fixture/conflict/.codex/config.toml" || fail 'config overwritten'
mkdir -p "$fixture/unignored"
git -C "$fixture/unignored" init -q
reject "$root/scripts/enable-reference-context.sh" "$fixture/unignored"
[ ! -e "$fixture/unignored/.codex/config.toml" ] || fail 'unignored runtime accepted'
mkdir -p "$fixture/parent-file"
git -C "$fixture/parent-file" init -q
printf '.cache/\n' > "$fixture/parent-file/.gitignore"
printf 'preserve\n' > "$fixture/parent-file/docs"
reject "$root/scripts/enable-reference-context.sh" "$fixture/parent-file"
[ ! -e "$fixture/parent-file/scripts/reference-search.sh" ] || fail 'partial parent conflict install'
mkdir -p "$fixture/symlink" "$fixture/outside"
git -C "$fixture/symlink" init -q
printf '.cache/\n' > "$fixture/symlink/.gitignore"
ln -s "$fixture/outside" "$fixture/symlink/docs"
reject "$root/scripts/enable-reference-context.sh" "$fixture/symlink"
[ ! -e "$fixture/outside/reference-context.md" ] || fail 'symlink escape'
state="$repo/.cache/reference-context"
mkdir -p "$state/bin" "$state/data"
printf '9550\n' > "$state/port"
printf 'fixture-secret\n' > "$state/data/admin.key"
cat > "$state/bin/xerj" <<'MOCK'
#!/usr/bin/env bash
[ "$XERJ_API_KEY" = fixture-secret ] || exit 9
[ "$XERJ_URL" = http://127.0.0.1:9550 ] || exit 10
[ "$XERJ_CODE_HOME" = "$EXPECT_STATE/code" ] || exit 11
[ "$XERJ_HUB_HOME" = "$EXPECT_STATE/hub" ] || exit 12
printf '%s\n' "$@"
MOCK
chmod +x "$state/bin/xerj"
export EXPECT_STATE="$state"
export XERJ_URL=https://example.invalid
export XERJ_CODE_HOME=/foreign
export XERJ_HUB_HOME=/foreign
"$repo/scripts/reference-search.sh" project 'quoted query with spaces' > "$fixture/args"
grep -qx 'quoted query with spaces' "$fixture/args" || fail 'query split'
grep -A1 -x -- '-k' "$fixture/args" | grep -qx 3 || fail 'passage budget'
grep -A1 -x -- '--full' "$fixture/args" | grep -qx 600 || fail 'character budget'
reject "$repo/scripts/reference-search.sh" project '--url=https://example.invalid'
reject "$repo/scripts/reference-search.sh" project query --no-ignore
reject "$repo/scripts/reference-search.sh" start query
reject "$repo/scripts/reference-search.sh" peer '../escape' query
reject "$repo/scripts/reference-search.sh" peer 'valid-name' query
printf 'full-commit-and-license-reviewed\n' > "$repo/docs/references/valid-name.json"
"$repo/scripts/reference-search.sh" peer valid-name query > "$fixture/peer"
grep -qx code "$fixture/peer" || fail 'wrong peer mode'
ln -s "$fixture/outside" "$state/code"
reject "$repo/scripts/reference-search.sh" project query
rm "$state/code"
printf '65534\n' > "$state/port"
reject "$repo/scripts/reference-search.sh" project query
printf '9550\n' > "$state/port"
git -C "$repo" add .
git -C "$repo" -c user.name=Fixture -c user.email=fixture@example.invalid commit -qm fixture
git -C "$repo" worktree add -q "$fixture/lane"
"$fixture/lane/scripts/reference-search.sh" project query > "$fixture/lane-args"
cmp "$fixture/args" "$fixture/lane-args" >/dev/null && fail 'query fixture unexpectedly equal'
grep -A1 -x -- '--prefix' "$fixture/args" > "$fixture/main-prefix"
grep -A1 -x -- '--prefix' "$fixture/lane-args" > "$fixture/lane-prefix"
cmp "$fixture/main-prefix" "$fixture/lane-prefix" || fail 'worktree namespace drift'
"$repo/scripts/check.sh"
echo 'Reference context contracts passed.'
