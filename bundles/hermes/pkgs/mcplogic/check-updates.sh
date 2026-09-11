#!/usr/bin/env bash
# Check mcplogic for upstream movement.
#
# Compares the pinned commit in default.nix against the main-branch HEAD and,
# when it moved, reports whether the dependency manifest changed. The upstream
# pnpm-lock.yaml comes with the new revision, so dependency changes mainly
# mean a new fetchPnpmDeps hash (and possibly a different pnpm major).
#
# Exit 0 when the pin is current, 1 when an update exists.
set -euo pipefail

REPO="autonull/mcplogic"
DEFAULT_NIX="$(dirname "$0")/default.nix"

pinned=$(grep -oE 'rev = "[a-f0-9]{40}"' "$DEFAULT_NIX" | sed -E 's/.*"([a-f0-9]{40})".*/\1/')
latest=$(curl -fsSL "https://api.github.com/repos/${REPO}/commits?per_page=1" | grep -oE '"sha": "[a-f0-9]{40}"' | head -1 | sed -E 's/.*"([a-f0-9]{40})".*/\1/')

echo "pinned: ${pinned}"
echo "latest: ${latest}"

if [[ "${pinned}" == "${latest}" ]]; then
  echo "mcplogic is up to date"
  exit 0
fi

echo "update available: ${pinned} -> ${latest}"

# Heuristic dependency-block diff; both revisions share the same file layout.
manifest_deps() {
  curl -fsSL "https://raw.githubusercontent.com/${REPO}/$1/package.json" | sed -n '\|"dependencies"\|"devDependencies"|,\|^  }|p'
}

old_deps=$(manifest_deps "${pinned}")
new_deps=$(manifest_deps "${latest}")

if [[ "${old_deps}" == "${new_deps}" ]]; then
  echo "dependencies unchanged; only src/pnpmDeps hashes need updating"
else
  echo "dependency drift detected (refresh fetchPnpmDeps hash):"
  diff <(printf '%s\n' "${old_deps}") <(printf '%s\n' "${new_deps}") || true
fi

exit 1
