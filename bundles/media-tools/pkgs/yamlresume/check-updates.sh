#!/usr/bin/env bash
# Check yamlresume for a newer upstream release.
#
# Compares the version pinned in default.nix against the latest release on
# the npm registry. Unlike the hermes packages there are no local patches
# to re-verify, but a version bump still needs the vendored files and
# hashes refreshed.
#
# Exit 0 when the pin is current, 1 when an update exists, 2 on check failure.
set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/../../../utils/pkgs/check-updates-lib.sh"
PKG="yamlresume"
DEFAULT_NIX="$(dirname "$0")/default.nix"
REPO_DIR="$(git rev-parse --show-toplevel)"

pinned=$(grep -oE 'version = "[0-9]+\.[0-9]+\.[0-9]+"' "$DEFAULT_NIX" | head -1 | sed -E 's/.*"([0-9]+\.[0-9]+\.[0-9]+)".*/\1/' || update_error "unable to find the pinned version in ${DEFAULT_NIX}")
[[ -n "$pinned" ]] || update_error "no pinned version found in ${DEFAULT_NIX}"
latest=$(latest_npm_version "$PKG")

echo "pinned: ${pinned}"
echo "latest: ${latest}"

if [[ "${pinned}" == "${latest}" ]]; then
  echo "yamlresume is up to date"
  exit 0
fi

WORK_DIR="$(mktemp -d)"

cat <<EOF
update available: ${pinned} -> ${latest}

to update:
  1. fetch the new tarball and regenerate the vendored files:
       cd "${WORK_DIR}"
       curl -fsSL -o pkg.tgz https://registry.npmjs.org/${PKG}/-/${PKG}-${latest}.tgz
       tar -xzOf pkg.tgz package/package.json > package.json
       node -e 'const fs=require("fs");const p=JSON.parse(fs.readFileSync("package.json"));delete p.devDependencies;delete p.scripts;fs.writeFileSync("package.json",JSON.stringify(p,null,2))'
       npm install --package-lock-only --ignore-scripts --no-audit --no-fund
       cp package.json package-lock.json "${REPO_DIR}/bundles/media-tools/pkgs/yamlresume/"
  2. update version, src.url, and src.hash in ${DEFAULT_NIX}:
       nix store prefetch-file --json https://registry.npmjs.org/${PKG}/-/${PKG}-${latest}.tgz
  3. set the new npmDepsHash:
       nix run --inputs-from "${REPO_DIR}" nixpkgs#prefetch-npm-deps -- "${REPO_DIR}/bundles/media-tools/pkgs/yamlresume/package-lock.json"
EOF

exit 1
