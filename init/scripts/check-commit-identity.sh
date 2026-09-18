#!/usr/bin/env bash
# check-commit-identity.sh — catch commit identities that won't survive a
# deploy or CI integration before they reach a PR.
#
# Many CI/CD and deploy integrations (Vercel, Netlify, and others) match a
# commit's author email to a connected git-hosting account before they'll
# build. When the email doesn't resolve to any account, the build is
# refused — often discovered only at deploy time, on a branch nobody is
# watching closely. This script fails loudly and early instead.
#
# Not every project uses such an integration, so this is opt-in: wire it
# into ./scripts/check.sh, a pre-push hook, or CI if it applies to you.
#
# Configure via COMMIT_IDENTITY_ALLOW, a comma-separated list of exact
# emails or domain suffixes (e.g. "*@yourcompany.com") that are known-good
# for your setup. Without it, only the universally-safe
# "@users.noreply.github.com" suffix passes.
set -euo pipefail

cd "$(dirname "$0")/.."

VALID_SUFFIX="@users.noreply.github.com"
ALLOW="${COMMIT_IDENTITY_ALLOW:-}"

is_valid() {
  local email="$1" pattern
  case "$email" in
    *"$VALID_SUFFIX") return 0 ;;
  esac
  [ -n "$ALLOW" ] || return 1
  IFS=',' read -ra patterns <<<"$ALLOW"
  for pattern in "${patterns[@]}"; do
    case "$email" in
      $pattern) return 0 ;;
    esac
  done
  return 1
}

fail() {
  echo ""
  echo "  BLOCKED: commit author email may not resolve on your deploy/CI integration."
  echo ""
  echo "    $1"
  echo ""
  echo "  Fix locally:"
  echo "    git config user.email \"you@users.noreply.github.com\""
  echo ""
  echo "  Or allow it explicitly if you've verified it resolves:"
  echo "    export COMMIT_IDENTITY_ALLOW=\"you@yourcompany.com,*@yourcompany.com\""
  echo ""
  exit 1
}

base="${COMMIT_IDENTITY_BASE:-origin/main}"
checked_commits=0
if git rev-parse --verify --quiet "$base" >/dev/null 2>&1; then
  checked_commits=1
  bad="$(git log "$base..HEAD" --format='%ae' 2>/dev/null | sort -u | while IFS= read -r email; do
    [ -z "$email" ] && continue
    is_valid "$email" || echo "$email"
  done)"
  if [ -n "$bad" ]; then
    fail "commits on this branch use: $(printf '%s' "$bad" | tr '\n' ' ')"
  fi
fi

configured="$(git config user.email 2>/dev/null || echo "")"
if [ -n "$configured" ]; then
  is_valid "$configured" || fail "configured user.email is '$configured'."
  echo "Commit identity OK ($configured)."
elif [ -n "${CI:-}" ]; then
  if [ "$checked_commits" = "1" ]; then
    echo "Commit identity OK (CI: no local identity, branch commits verified)."
  else
    echo "Commit identity: CI without '$base' to compare against — nothing to verify."
  fi
else
  fail "no user.email is configured at all."
fi
