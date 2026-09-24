#!/usr/bin/env bash
# Check simple-english for upstream movement.
#
# Compares the pinned tag in default.nix against the newest upstream tag.
# The package vendors only the skill files (no dependencies, no build), so a
# new tag only ever means updating `version`, `tag`, and the src hash in
# default.nix.
#
# Exit 0 when the pin is current, 1 when an update exists.
set -euo pipefail

REPO="AminBlg/SimpleEnglish"
DEFAULT_NIX="$(dirname "$0")/default.nix"

pinned=$(grep -oE 'tag = "v[0-9]+\.[0-9]+\.[0-9]+"' "$DEFAULT_NIX" | sed -E 's/.*"(v[0-9.]+)".*/\1/')
latest=$(curl -fsSL "https://api.github.com/repos/${REPO}/tags" | grep -oE '"name": "v[0-9]+\.[0-9]+\.[0-9]+"' | head -1 | sed -E 's/.*"(v[0-9.]+)".*/\1/')

echo "pinned: ${pinned}"
echo "latest: ${latest}"

if [[ "${pinned}" == "${latest}" ]]; then
  echo "simple-english is up to date"
  exit 0
fi

echo "update available: ${pinned} -> ${latest}"
exit 1
