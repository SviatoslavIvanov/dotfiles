#!/usr/bin/env bash
# Nix owns declared leaves, not entire objects such as permissions or sandbox.
set -euo pipefail
umask 077

target=$1
managed=$2
mkdir -p "$(dirname "$target")"
tmp=$(mktemp "$target.XXXXXX")
trap 'rm -f "$tmp"' EXIT

# Validate both documents before replacing files or following old symlinks.
jq -e -s 'length == 1 and (.[0] | type == "object")' "$managed" >/dev/null
if [ -e "$target" ] || [ -L "$target" ]; then
  jq -e -s 'length == 1 and (.[0] | type == "object")' "$target" >/dev/null
  jq -s '.[0] * .[1]' "$target" "$managed" > "$tmp"
else
  jq . "$managed" > "$tmp"
fi
# Same-directory rename is atomic and never writes through an old symlink.
mv -f "$tmp" "$target"
