#!/usr/bin/env bash
# Nix owns declared top-level keys; Pi owns device IDs, changelog state, etc.
set -euo pipefail
umask 077

target=$1
managed=$2
mkdir -p "$(dirname "$target")"
tmp=$(mktemp "$target.XXXXXX")
trap 'rm -f "$tmp"' EXIT

# Validate before replacing anything; malformed/empty files must not lose data.
jq -e -s 'length == 1 and (.[0] | type == "object")' "$managed" >/dev/null
if [ -e "$target" ] || [ -L "$target" ]; then
  jq -e -s 'length == 1 and (.[0] | type == "object")' "$target" >/dev/null
  jq -s '.[0] + .[1]' "$target" "$managed" > "$tmp"
else
  jq . "$managed" > "$tmp"
fi
# Atomic replacement also migrates an old symlink without writing through it.
mv -f "$tmp" "$target"
