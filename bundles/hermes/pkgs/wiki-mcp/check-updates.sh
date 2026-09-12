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
#     -> vitest >= 4.1.11 and tsup >= 8.5.1 (esbuild >= 0.28.1 then closes
#        via its tree; the npm overrides entry can go with the patch)
#
# The floor check below reports which patches can be dropped before the next
# update. Removing a patch means deleting it from `patches` in default.nix
# and deleting the file itself.
#
# Exit 0 when the pin is current, 1 when an update exists.
set -euo pipefail

REPO="Mohan-Kumar-Swamynathan/wiki-mcp"
DEFAULT_NIX="$(dirname "$0")/default.nix"

pinned=$(grep -oE 'rev = "[a-f0-9]{40}"' "$DEFAULT_NIX" | sed -E 's/.*"([a-f0-9]{40})".*/\1/')
latest=$(curl -fsSL "https://api.github.com/repos/${REPO}/commits?per_page=1" | grep -oE '"sha": "[a-f0-9]{40}"' | head -1 | sed -E 's/.*"([a-f0-9]{40})".*/\1/')

# Compare semver-ish versions numerically. Returns 0 (true) when the
# discovered version is >= the floor. Version parts missing from the floor
# count as wildcards; extra parts in the discovered version count as zero.
version_at_least() {
  local ver="$1" floor="$2" v f
  IFS=. read -ra v <<<"$ver"
  IFS=. read -ra f <<<"$floor"
  local i
  for i in "${!f[@]}"; do
    if ((${v[i]:-0} > f[i])); then return 0; fi
    if ((${v[i]:-0} < f[i])); then return 1; fi
  done
  return 0
}

latest_manifest=$(curl -fsSL "https://raw.githubusercontent.com/${REPO}/${latest}/package.json")

# Probe one dependency; emit a hint when the discovered upstream version
# meets the removal floor.
check_floor() {
  local dep="$1" floor="$2" note="$3"
  local ver
  ver=$(grep -oE "\"${dep}\": \"\^?[0-9]+\.[0-9]+(\.[0-9]+)?\"" <<<"$latest_manifest" | grep -oE "[0-9]+\.[0-9]+(\.[0-9]+)?")
  if [[ -n "$ver" ]] && version_at_least "$ver" "$floor"; then
    echo "patch can go: ${note} (upstream ${dep} ${ver} >= ${floor})"
  fi
}

echo "pinned: ${pinned}"
echo "latest: ${latest}"

# Extract the dependency blocks from package.json at each revision. Heuristic
# (not a JSON parse), but both sides use the same file layout so the diff is
# meaningful.
manifest_deps() {
  printf '%s' "$latest_manifest" | sed -n '\|"dependencies"\|"devDependencies"|,\|^  }|p'
}

if [[ "${pinned}" == "${latest}" ]]; then
  new_deps=$(manifest_deps)
  echo "wiki-mcp is up to date"
  check_floor "@mozilla/readability" "0.6.0" "drop 0001-security-readability-0.6.0.patch" || true
  check_floor "vitest" "4.1.11" "drop 0002-security-vitest4-tsup8-esbuild-override.patch (with tsup >= 8.5.1)" || true
  check_floor "tsup" "8.5.1" "drop 0002-security-vitest4-tsup8-esbuild-override.patch (with vitest >= 4.1.11)" || true
  exit 0
fi

echo "update available: ${pinned} -> ${latest}"

old_deps=$(curl -fsSL "https://raw.githubusercontent.com/${REPO}/${pinned}/package.json" | sed -n '\|"dependencies"\|"devDependencies"|,\|^  }|p')
new_deps=$(manifest_deps)

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

check_floor "@mozilla/readability" "0.6.0" "drop 0001-security-readability-0.6.0.patch" || true
check_floor "vitest" "4.1.11" "drop 0002-security-vitest4-tsup8-esbuild-override.patch (with tsup >= 8.5.1)" || true
check_floor "tsup" "8.5.1" "drop 0002-security-vitest4-tsup8-esbuild-override.patch (with vitest >= 4.1.11)" || true

exit 1
