#!/usr/bin/env bash
# Check wiki-mcp for upstream movement.
#
# Compares the pinned commit in default.nix against the main-branch HEAD and,
# when it moved, reports whether the dependency manifest changed. Dependency
# changes mean the vendored package-lock.json must be regenerated; a bare
# version bump only needs new src/npmDepsHash values.
#
# Exit 0 when the pin is current, 1 when an update exists.
set -euo pipefail

REPO="Mohan-Kumar-Swamynathan/wiki-mcp"
DEFAULT_NIX="$(dirname "$0")/default.nix"

pinned=$(grep -oE 'rev = "[a-f0-9]{40}"' "$DEFAULT_NIX" | sed -E 's/.*"([a-f0-9]{40})".*/\1/')
latest=$(curl -fsSL "https://api.github.com/repos/${REPO}/commits?per_page=1" | grep -oE '"sha": "[a-f0-9]{40}"' | head -1 | sed -E 's/.*"([a-f0-9]{40})".*/\1/')

echo "pinned: ${pinned}"
echo "latest: ${latest}"

if [[ "${pinned}" == "${latest}" ]]; then
  echo "wiki-mcp is up to date"
  exit 0
fi

echo "update available: ${pinned} -> ${latest}"

# Extract the dependency blocks from package.json at each revision. Heuristic
# (not a JSON parse), but both sides use the same file layout so the diff is
# meaningful.
manifest_deps() {
  curl -fsSL "https://raw.githubusercontent.com/${REPO}/$1/package.json" | sed -n '\|"dependencies"\|"devDependencies"|,\|^  }|p'
}

old_deps=$(manifest_deps "${pinned}")
new_deps=$(manifest_deps "${latest}")

if [[ "${old_deps}" == "${new_deps}" ]]; then
  echo "dependencies unchanged; only src/npmDepsHash need updating"
else
  echo "dependency drift detected:"
  diff <(printf '%s\n' "${old_deps}") <(printf '%s\n' "${new_deps}") || true
  echo "regenerate the lockfile, then update src/npmDepsHash:"
  echo "  git clone https://github.com/${REPO}.git && cd wiki-mcp"
  echo "  npm install --package-lock-only"
  echo "  cp package-lock.json bundles/hermes/pkgs/wiki-mcp/package-lock.json"
fi

exit 1
