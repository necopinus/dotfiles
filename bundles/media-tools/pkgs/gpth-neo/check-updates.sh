#!/usr/bin/env bash
# Check gpth-neo for a newer upstream release.
#
# A version bump also requires regenerating pubspec.lock.json and refreshing
# the source hash. If the Git dependency moves, its Nix hash must change too.
# The help-shutdown patch must be checked against every new upstream release.
# Exit 0 when the pin is current, 1 when an update exists, 2 on check failure.
set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/../../../utils/pkgs/check-updates-lib.sh"
REPO="Xentraxx/GooglePhotosTakeoutHelper_Neo"
DEFAULT_NIX="$(dirname "$0")/default.nix"
REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
PKG_DIR="${REPO_ROOT}/bundles/media-tools/pkgs/gpth-neo"

pinned=$(grep -oE 'version = "[0-9]+\.[0-9]+\.[0-9]+"' "$DEFAULT_NIX" | head -1 | sed -E 's/.*"([0-9]+\.[0-9]+\.[0-9]+)".*/\1/' || update_error "unable to find the pinned version in ${DEFAULT_NIX}")
[[ -n "$pinned" ]] || update_error "no pinned version found in ${DEFAULT_NIX}"
latest=$(latest_tag "$REPO")
latest=${latest#v}

echo "pinned: ${pinned}"
echo "latest: ${latest}"

if [[ "${pinned}" == "${latest}" ]]; then
  echo "gpth-neo is up to date"
  exit 0
fi

WORK_DIR="$(mktemp -d)"

cat <<EOF
update available: ${pinned} -> ${latest}

to update:
  1. fetch the new lockfile and convert it to JSON:
       curl -fsSL https://github.com/${REPO}/archive/refs/tags/v${latest}.tar.gz | \
         tar -xzOf - GooglePhotosTakeoutHelper_Neo-${latest}/pubspec.lock > "${WORK_DIR}/pubspec.lock"
       nix run --inputs-from "${REPO_ROOT}" nixpkgs#yq-go -- -o=json . "${WORK_DIR}/pubspec.lock" > "${PKG_DIR}/pubspec.lock.json"
  2. update version and src.hash in ${DEFAULT_NIX}:
       nix store prefetch-file --unpack --json https://github.com/${REPO}/archive/refs/tags/v${latest}.tar.gz
  3. if the lockfile changed the image dependency's resolved-ref, prefetch
     that commit and update gitHashes.image:
       nix run --inputs-from "${REPO_ROOT}" nixpkgs#nix-prefetch-git -- \
         --url https://github.com/Xentraxx/image.git --rev RESOLVED_REF
  4. make sure that dispose-after-help.patch still applies. Remove it if
     upstream now disposes services before returning from --help.
  5. build .#checks.x86_64-linux.gpth-neo and .#checks.aarch64-darwin.gpth-neo.
EOF

exit 1
