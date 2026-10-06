#!/usr/bin/env bash
# scan-secrets.sh — fail when a source file holds a live session or JWT.
#
# Filename-based checks (".env", "*.pem") miss the common leak: a real cookie
# jar or token pasted into an ordinary source file while debugging, with a
# normal name and extension. This scans file CONTENTS for two independent
# signals, either sufficient, both rare in legitimate source:
#
#   1. a JWT literal (two dot-joined base64url segments that both start eyJ)
#   2. a cookie-jar literal: 3+ "; name=value" pairs AND a session-ish key
#
# Scans tracked and untracked-but-not-ignored files, so it works as a
# pre-commit check as well as in CI. Some JWTs are meant to be public (for
# example a client-side anon key); list those paths in .secret-scan-ignore,
# one per line — an exact path, or a directory prefix ending in "/".
set -euo pipefail

cd "$(dirname "$0")/.."

IGNORE_FILE=".secret-scan-ignore"

# Without a git repo the file list below is silently empty and the scan would
# report a clean result it never earned.
git rev-parse --git-dir >/dev/null 2>&1 || { echo "scan-secrets: not inside a git repository." >&2; exit 2; }

is_ignored() {
  local path="$1" pattern
  [ -f "$IGNORE_FILE" ] || return 1
  while IFS= read -r pattern || [ -n "$pattern" ]; do
    case "$pattern" in ''|\#*) continue ;; esac
    case "$pattern" in
      */) case "$path" in "$pattern"*) return 0 ;; esac ;;
      *) [ "$path" = "$pattern" ] && return 0 ;;
    esac
  done <"$IGNORE_FILE"
  return 1
}

hits=""
while IFS= read -r f; do
  [ -f "$f" ] || continue
  case "$f" in
    package-lock.json|*/package-lock.json|pnpm-lock.yaml|*/pnpm-lock.yaml|yarn.lock|*/yarn.lock) continue ;;
  esac
  is_ignored "$f" && continue
  if grep -qE 'eyJ[A-Za-z0-9_-]{8,}\.eyJ[A-Za-z0-9_-]{8,}' "$f" 2>/dev/null; then
    hits="$hits $f(jwt)"
  elif grep -qE '(;[[:space:]]*[A-Za-z0-9_-]+=[^;]*){3,}' "$f" 2>/dev/null \
    && grep -qiE '(ssid|_csrf|csrf_token|sessionid|session_id|auth_token)=[A-Za-z0-9%_.-]{6,}' "$f" 2>/dev/null; then
    hits="$hits $f(cookie-jar)"
  fi
done < <(git ls-files --cached --others --exclude-standard -- \
  '*.ts' '*.tsx' '*.js' '*.jsx' '*.mjs' '*.cjs' '*.py' '*.rb' '*.go' '*.sh' \
  '*.json' '*.yml' '*.yaml' '*.toml' '*.txt' '*.patch' 2>/dev/null)

if [ -n "$hits" ]; then
  echo "A source file appears to contain a live session or JWT:$hits" >&2
  echo "Never commit a real cookie jar, CSRF token or JWT. Read secrets from .env at runtime." >&2
  echo "If a hit is intentionally public, list its path in $IGNORE_FILE." >&2
  exit 1
fi

echo "No live sessions or JWT literals found in source files."
