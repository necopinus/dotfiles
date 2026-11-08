#!/usr/bin/env bash
# Check mcplogic for upstream movement.
#
# Compares the pinned commit in default.nix against the main-branch HEAD and,
# when it moved, reports whether the dependency manifest changed. The upstream
# pnpm-lock.yaml comes with the new revision, so dependency changes mainly
# mean a new fetchPnpmDeps hash (and possibly a different pnpm major).
#
# Exit 0 when the pin is current, 1 when an update exists, 2 on check failure.
set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/../../../utils/pkgs/check-updates-lib.sh"
REPO="autonull/mcplogic"
DEFAULT_NIX="$(dirname "$0")/default.nix"

pinned=$(grep -oE 'rev = "[a-f0-9]{40}"' "$DEFAULT_NIX" | sed -E 's/.*"([a-f0-9]{40})".*/\1/' || update_error "unable to find the pinned revision in ${DEFAULT_NIX}")
[[ -n "$pinned" ]] || update_error "no pinned revision found in ${DEFAULT_NIX}"
latest=$(latest_commit "$REPO")

echo "pinned: ${pinned}"
echo "latest: ${latest}"

if [[ "${pinned}" == "${latest}" ]]; then
  echo "mcplogic is up to date"
  exit 0
fi

echo "update available: ${pinned} -> ${latest}"

# Compare dependency blocks with a JSON parser. The output is stable for diff.
manifest_deps() {
  python3 -c '
import json
import sys

data = json.load(sys.stdin)
for section in ("dependencies", "devDependencies"):
    if section in data:
        print(f"{section}: {json.dumps(data[section], sort_keys=True)}")
' <<<"$1"
}

old_manifest=$(fetch_url "https://raw.githubusercontent.com/${REPO}/${pinned}/package.json")
new_manifest=$(fetch_url "https://raw.githubusercontent.com/${REPO}/${latest}/package.json")
old_deps=$(manifest_deps "$old_manifest")
new_deps=$(manifest_deps "$new_manifest")

if [[ "${old_deps}" == "${new_deps}" ]]; then
  echo "dependencies unchanged; only src/pnpmDeps hashes need updating"
else
  echo "dependency drift detected (refresh fetchPnpmDeps hash):"
  diff <(printf '%s\n' "${old_deps}") <(printf '%s\n' "${new_deps}") || true
fi

exit 1
