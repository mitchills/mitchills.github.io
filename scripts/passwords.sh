#!/usr/bin/env bash
#
# Prints the password for every file in public-encrypted/.
# Passwords are derived (not stored) — same secret + path => same password.
# Run:  bash scripts/passwords.sh

set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

if [ ! -f .env ]; then
  echo "ERROR: .env not found." >&2; exit 1
fi
# shellcheck disable=SC1091
set -a; source .env; set +a
MASTER="${STATICRYPT_MASTER_SECRET:-}"
[ -n "$MASTER" ] || { echo "ERROR: STATICRYPT_MASTER_SECRET missing from .env." >&2; exit 1; }

hmac() { printf '%s' "$2" | openssl dgst -sha256 -hmac "$1" | sed 's/^.*= //'; }

SRC="public-encrypted"
[ -d "$SRC" ] || { echo "No $SRC/ folder yet."; exit 0; }

printf '%-45s  %s\n' "FILE (live path)" "PASSWORD"
printf '%-45s  %s\n' "---------------------------------------------" "------------------------"
find "$SRC" -type f -name '*.html' | sort | while read -r file; do
  rel="${file#"$SRC"/}"
  pass="$(hmac "$MASTER" "$rel" | cut -c1-24)"
  printf '%-45s  %s\n' "/$rel" "$pass"
done
