#!/usr/bin/env bash
# Check wiki-mcp for upstream movement and whether local patches are stale.
#
# Compares the pinned commit in default.nix against the main-branch HEAD and,
# when it moved, reports whether the dependency manifest changed. Dependency
# changes mean the vendored package-lock.json must be regenerated; a bare
# version bump only needs new src/npmDepsHash values.
#
# The local security patches (see the `patches` comment in default.nix) are
# stale once upstream pins the fixed floors, per the removal conditions:
#
#   0001-security-readability-0.6.0.patch   -> @mozilla/readability >= 0.6.0
#   0002-security-vitest4-tsup8-esbuild-override.patch
#     -> vitest >= 4.1.12 and tsup >= 8.5.1 (esbuild >= 0.28.1 then closes
#        via its tree; the npm overrides entry can go with the patch)
#
# Exit 0 when the pin is current, 1 when an update exists, 2 on check failure.
set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/../../../utils/pkgs/check-updates-lib.sh"
REPO="Mohan-Kumar-Swamynathan/wiki-mcp"
DEFAULT_NIX="$(dirname "$0")/default.nix"
REPO_DIR="$(git rev-parse --show-toplevel)"

pinned=$(grep -oE 'rev = "[a-f0-9]{40}"' "$DEFAULT_NIX" | sed -E 's/.*"([a-f0-9]{40})".*/\1/' || update_error "unable to find the pinned revision in ${DEFAULT_NIX}")
[[ -n "$pinned" ]] || update_error "no pinned revision found in ${DEFAULT_NIX}"
latest=$(latest_commit "$REPO")
latest_manifest=$(fetch_url "https://raw.githubusercontent.com/${REPO}/${latest}/package.json")

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

# Probe one dependency; emit a hint when the discovered upstream version
# meets the removal floor.
check_floor() {
  local dep="$1" floor="$2" note="$3"
  local ver
  ver=$(json_dependency_version "$dep" <<<"$latest_manifest" || true)
  if [[ -n "$ver" ]] && version_at_least "$ver" "$floor"; then
    echo "patch can go: ${note} (upstream ${dep} ${ver} >= ${floor})"
  fi
}

echo "pinned: ${pinned}"
echo "latest: ${latest}"

if [[ "${pinned}" == "${latest}" ]]; then
  echo "wiki-mcp is up to date"
  check_floor "@mozilla/readability" "0.6.0" "drop 0001-security-readability-0.6.0.patch" || true
  check_floor "vitest" "4.1.12" "drop 0002-security-vitest4-tsup8-esbuild-override.patch (with tsup >= 8.5.1)" || true
  check_floor "tsup" "8.5.1" "drop 0002-security-vitest4-tsup8-esbuild-override.patch (with vitest >= 4.1.12)" || true
  exit 0
fi

echo "update available: ${pinned} -> ${latest}"

old_manifest=$(fetch_url "https://raw.githubusercontent.com/${REPO}/${pinned}/package.json")
old_deps=$(manifest_deps "$old_manifest")
new_deps=$(manifest_deps "$latest_manifest")

if [[ "${old_deps}" == "${new_deps}" ]]; then
  echo "dependencies unchanged; only src/npmDepsHash need updating"
else
  echo "dependency drift detected:"
  diff <(printf '%s\n' "${old_deps}") <(printf '%s\n' "${new_deps}") || true
  echo "regenerate the lockfile from the pinned revision with both security patches applied:"
  echo "  git clone https://github.com/${REPO}.git && cd wiki-mcp"
  echo "  git checkout ${latest}"
  echo "  git apply ${REPO_DIR}/bundles/hermes/pkgs/wiki-mcp/0001-security-readability-0.6.0.patch"
  echo "  git apply ${REPO_DIR}/bundles/hermes/pkgs/wiki-mcp/0002-security-vitest4-tsup8-esbuild-override.patch"
  echo "  npm install --package-lock-only"
  echo "  cp package-lock.json ${REPO_DIR}/bundles/hermes/pkgs/wiki-mcp/package-lock.json"
  echo "keep the transitive security floors listed in default.nix when you do"
fi

check_floor "@mozilla/readability" "0.6.0" "drop 0001-security-readability-0.6.0.patch" || true
check_floor "vitest" "4.1.12" "drop 0002-security-vitest4-tsup8-esbuild-override.patch (with tsup >= 8.5.1)" || true
check_floor "tsup" "8.5.1" "drop 0002-security-vitest4-tsup8-esbuild-override.patch (with vitest >= 4.1.12)" || true

exit 1
