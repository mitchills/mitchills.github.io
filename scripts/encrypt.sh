#!/usr/bin/env bash
#
# Encrypts every HTML file in public-encrypted/ into public/ using StatiCrypt.
# Each file gets its own password, derived from the master secret + the file's
# path (HMAC-SHA256). Same secret + same path => same password every time.
#
# Runs automatically via the pre-commit hook. You never run this by hand.

set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

SRC="public-encrypted"
OUT="public"

# --- load the master secret -------------------------------------------------
if [ ! -f .env ]; then
  echo "ERROR: .env not found — cannot encrypt. Aborting commit." >&2
  exit 1
fi
# shellcheck disable=SC1091
set -a; source .env; set +a
MASTER="${STATICRYPT_MASTER_SECRET:-}"
if [ -z "$MASTER" ]; then
  echo "ERROR: STATICRYPT_MASTER_SECRET missing from .env. Aborting commit." >&2
  exit 1
fi

# nothing to encrypt? that's fine
[ -d "$SRC" ] || { echo "No $SRC/ folder — nothing to encrypt."; exit 0; }
if ! find "$SRC" -type f -name '*.html' | read -r _; then
  echo "No HTML files in $SRC/ — nothing to encrypt."
  exit 0
fi

# deterministic salt (32 hex chars) derived from the master secret
hmac() { printf '%s' "$2" | openssl dgst -sha256 -hmac "$1" | sed 's/^.*= //'; }
SALT="$(hmac "$MASTER" "staticrypt-salt" | cut -c1-32)"

# --- encrypt each file ------------------------------------------------------
find "$SRC" -type f -name '*.html' | while read -r file; do
  rel="${file#"$SRC"/}"                 # e.g. reports/client-weekly.html
  reldir="$(dirname "$rel")"
  targetdir="$OUT/$reldir"
  mkdir -p "$targetdir"

  # per-file password from master secret + relative path
  pass="$(hmac "$MASTER" "$rel" | cut -c1-24)"

  npx --no-install staticrypt "$file" \
      --password "$pass" \
      --salt "$SALT" \
      --short \
      --directory "$targetdir" \
      --config false >/dev/null

  git add "$targetdir/$(basename "$file")"
  echo "  encrypted: $rel"
done

echo "Encryption complete → $OUT/"
