#!/usr/bin/env bash
# Check scimath-mcp for upstream movement and dependency drift.
#
# Two checks run regardless of which one trips first:
#
# 1. New tag: compares the pinned tag in default.nix against the newest
#    upstream tag.
#
# 2. Dependency drift: prints the pinned tag's pyproject pins next to the
#    python3Package versions in the nixpkgs this repo is locked to. Drift
#    (like the mpmath<1.4 vs 1.4.1 case) breaks the build and must be
#    addressed with pins, relaxes, or overrides in default.nix.
#
# Exit 0 when the pin is current and every dependency resolves in nixpkgs,
# 1 otherwise.
set -euo pipefail

REPO="matheusbgodoi/scimath-mcp"
DEFAULT_NIX="$(dirname "$0")/default.nix"
REPO_ROOT=$(cd "$(dirname "$0")/../../.." && pwd)

# Runtime dependencies from pyproject.toml, mapped to python3Packages attrs.
DEPS=(
  mcp
  mpmath
  numpy
  pint
  pydantic
  scipy
  sympy
  uncertainties
)

pinned=$(grep -oE 'tag = "v[0-9]+\.[0-9]+\.[0-9]+"' "$DEFAULT_NIX" | sed -E 's/.*"(v[0-9.]+)".*/\1/')
latest=$(curl -fsSL "https://api.github.com/repos/${REPO}/tags" | grep -oE '"name": "v[0-9]+\.[0-9]+\.[0-9]+"' | head -1 | sed -E 's/.*"(v[0-9.]+)".*/\1/')

status=0

echo "pinned: ${pinned}"
echo "latest: ${latest}"

if [[ "${pinned}" == "${latest}" ]]; then
  echo "scimath-mcp is up to date"
else
  echo "update available: ${pinned} -> ${latest}"
  status=1
fi

# The pyproject pin for each dependency, e.g. `mcp==2.0.0`.
pins=$(curl -fsSL "https://raw.githubusercontent.com/${REPO}/${pinned}/pyproject.toml" | sed -n '/^dependencies = \[/,/\]/p' | grep -oE '"[a-z0-9_-]+[^"]*"' | tr -d '"')

for dep in "${DEPS[@]}"; do
  pin=$(grep -oE "^${dep}.*" <<<"${pins}" || echo "?")
  version=$(nix eval --raw --inputs-from "${REPO_ROOT}" "nixpkgs#python3Packages.${dep}.version" 2>/dev/null || echo "MISSING")
  if [[ "${version}" == "MISSING" ]]; then
    echo "drift: ${dep} (${pin}) is not in python3Packages"
    status=1
  else
    echo "  ${dep}: pyproject ${pin} -> nixpkgs ${version}"
  fi
done

# Known carve-outs in default.nix that make unsatisfied pins build anyway:
# mcp is overridden to 2.0.0 privately; mpmath is covered by pythonRelaxDeps.
echo "note: mcp is privately overridden to 2.0.0; mpmath pin is relaxed"

exit "${status}"
