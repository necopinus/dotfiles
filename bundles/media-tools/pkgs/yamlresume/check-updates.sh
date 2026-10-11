#!/usr/bin/env bash
# Check yamlresume for a newer upstream release.
#
# Compares the version pinned in default.nix against the latest release on
# the npm registry. Unlike the hermes packages there are no local patches
# to re-verify, but a version bump still needs the vendored files and
# hashes refreshed.
#
# Exit 0 when the pin is current, 1 when an update exists.
set -euo pipefail

PKG="yamlresume"
DEFAULT_NIX="$(dirname "$0")/default.nix"

pinned=$(grep -oE 'version = "[0-9]+\.[0-9]+\.[0-9]+"' "$DEFAULT_NIX" | head -1 | sed -E 's/.*"([0-9]+\.[0-9]+\.[0-9]+)".*/\1/')
latest=$(curl -fsSL "https://registry.npmjs.org/${PKG}/latest" | grep -oE '"version": ?"[0-9]+\.[0-9]+\.[0-9]+"' | head -1 | sed -E 's/.*"([0-9]+\.[0-9]+\.[0-9]+)".*/\1/')

echo "pinned: ${pinned}"
echo "latest: ${latest}"

if [[ "${pinned}" == "${latest}" ]]; then
  echo "yamlresume is up to date"
  exit 0
fi

echo "update available: ${pinned} -> ${latest}"
echo
echo "to update:"
echo "  1. fetch the new tarball and regenerate the vendored files:"
echo "       cd \$(mktemp -d)"
echo "       curl -fsSL -o pkg.tgz https://registry.npmjs.org/${PKG}/-/${PKG}-\${latest}.tgz"
echo "       tar -xzOf pkg.tgz package/package.json > package.json"
echo "       node -e 'const fs=require(\"fs\");const p=JSON.parse(fs.readFileSync(\"package.json\"));delete p.devDependencies;delete p.scripts;fs.writeFileSync(\"package.json\",JSON.stringify(p,null,2))'"
echo "       npm install --package-lock-only --ignore-scripts --no-audit --no-fund"
echo "       cp package.json package-lock.json bundles/media-tools/pkgs/yamlresume/"
echo "  2. in default.nix, bump version and set the new src hash:"
echo "       nix store prefetch-file --json https://registry.npmjs.org/${PKG}/-/${PKG}-\${latest}.tgz"
echo "  3. set the new npmDepsHash:"
echo "       nix run --inputs-from . nixpkgs#prefetch-npm-deps -- bundles/media-tools/pkgs/yamlresume/package-lock.json"

exit 1
