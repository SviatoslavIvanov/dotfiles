#!/usr/bin/env bash
# Retire only the old installer's Homebrew shim; never touch auth or sessions.
set -euo pipefail

launcher=$1
installer=$2
nix_pi=$3
backup="$launcher.pi-installer-backup"

[ -x "$nix_pi" ] || { echo "Nix Pi is missing: $nix_pi" >&2; exit 1; }
[ -L "$launcher" ] || exit 0
[ "$(readlink -f "$launcher")" = "$(readlink -f "$installer")" ] || exit 0
if [ -e "$backup" ] || [ -L "$backup" ]; then
  echo "Refusing to overwrite Pi launcher backup: $backup" >&2
  exit 1
fi
mv "$launcher" "$backup"
echo "Retired installer shim: $launcher (backup: $backup)" >&2
