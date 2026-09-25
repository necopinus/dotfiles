#!/usr/bin/env bash
# Check context-mode for upstream movement and dependency drift.
#
# Compares the pinned tag in default.nix against the newest upstream tag.
# When it moved, reports whether the dependency manifest changed: dependency
# changes mean the vendored package-lock.json must be regenerated, a bare
# version bump only needs new src/npmDepsHash values.
#
# The local patches (see the comment block in default.nix) are stale once
# upstream makes them unnecessary:
#
#   0001-stability-skip-better-sqlite3-probe-on-modern-node.patch
#     -> ensureNativeCompat no longer probes better-sqlite3 when the runtime
#        will use node:sqlite (manual check; no version floor)
#   0002-security-esbuild-0.28.2.patch -> esbuild >= 0.28.2
#
# The esbuild floor check below reports when patch 0002 can be dropped.
#
# Also watch the runtime layout contract (see the packaging notes in
# default.nix): start.mjs's boot gate derives required files from
# package.json, and the esbuild externals list in `scripts.bundle`
# determines what must ship in node_modules.
#
# Exit 0 when the pin is current, 1 when an update exists.
set -euo pipefail

REPO="mksglu/context-mode"
DEFAULT_NIX="$(dirname "$0")/default.nix"

pinned=$(grep -oE 'tag = "v[0-9]+\.[0-9]+\.[0-9]+"' "$DEFAULT_NIX" | sed -E 's/.*"(v[0-9.]+)".*/\1/')
latest=$(curl -fsSL "https://api.github.com/repos/${REPO}/tags?per_page=100" | grep -oE '"name": "v[0-9]+\.[0-9]+\.[0-9]+"' | head -1 | sed -E 's/.*"(v[0-9.]+)".*/\1/')

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

# Probe one dependency in the latest manifest; emit a hint when the
# discovered upstream version meets the removal floor.
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

if [[ "${pinned}" == "${latest}" ]]; then
  echo "context-mode is up to date"
  check_floor "esbuild" "0.28.2" "drop 0002-security-esbuild-0.28.2.patch" || true
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
  echo "dependencies unchanged; only src/npmDepsHash need updating"
else
  echo "dependency drift detected:"
  diff <(printf '%s\n' "${old_deps}") <(printf '%s\n' "${new_deps}") || true
  echo "regenerate the lockfile from the patched manifest, then update src/npmDepsHash:"
  echo "  git clone https://github.com/${REPO}.git && cd context-mode && git checkout ${latest}"
  echo "  # apply the 0002 patch's esbuild bump to package.json, then:"
  echo "  npm install --package-lock-only"
  echo "  cp package-lock.json <dotfiles>/bundles/opencode/pkgs/context-mode/package-lock.json"
fi

check_floor "esbuild" "0.28.2" "drop 0002-security-esbuild-0.28.2.patch" || true

exit 1
