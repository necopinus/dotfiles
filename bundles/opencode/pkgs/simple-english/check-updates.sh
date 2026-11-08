#!/usr/bin/env bash
# Check simple-english for upstream movement.
#
# Compares the pinned tag in default.nix against the newest upstream tag.
# The package vendors only the skill files (no dependencies, no build), so a
# new tag only ever means updating `version`, `tag`, and the src hash in
# default.nix.
#
# Exit 0 when the pin is current, 1 when an update exists, 2 on check failure.
set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/../../../utils/pkgs/check-updates-lib.sh"
REPO="AminBlg/SimpleEnglish"
DEFAULT_NIX="$(dirname "$0")/default.nix"

pinned=$(grep -oE 'tag = "v[0-9]+\.[0-9]+\.[0-9]+"' "$DEFAULT_NIX" | sed -E 's/.*"(v[0-9.]+)".*/\1/' || update_error "unable to find the pinned tag in ${DEFAULT_NIX}")
[[ -n "$pinned" ]] || update_error "no pinned tag found in ${DEFAULT_NIX}"
latest=$(latest_tag "$REPO")

echo "pinned: ${pinned}"
echo "latest: ${latest}"

if [[ "${pinned}" == "${latest}" ]]; then
  echo "simple-english is up to date"
  exit 0
fi

echo "update available: ${pinned} -> ${latest}"
exit 1
