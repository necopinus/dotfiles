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
# 1 otherwise, 2 on check failure.
set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/../../../utils/pkgs/check-updates-lib.sh"
REPO="matheusbgodoi/scimath-mcp"
DEFAULT_NIX="$(dirname "$0")/default.nix"
REPO_ROOT="$(git rev-parse --show-toplevel)"

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

pinned=$(grep -oE 'tag = "v[0-9]+\.[0-9]+\.[0-9]+"' "$DEFAULT_NIX" | sed -E 's/.*"(v[0-9.]+)".*/\1/' || update_error "unable to find the pinned tag in ${DEFAULT_NIX}")
[[ -n "$pinned" ]] || update_error "no pinned tag found in ${DEFAULT_NIX}"
latest=$(latest_tag "$REPO")

status=0

echo "pinned: ${pinned}"
echo "latest: ${latest}"

if [[ "${pinned}" == "${latest}" ]]; then
  echo "scimath-mcp is up to date"
else
  echo "update available: ${pinned} -> ${latest}"
  status=1
fi

# Read dependency constraints once and evaluate all nixpkgs versions once.
pins=$(fetch_url "https://raw.githubusercontent.com/${REPO}/${pinned}/pyproject.toml" | python3 -c '
import re
import sys
import tomllib

data = tomllib.loads(sys.stdin.read())
for requirement in data["project"]["dependencies"]:
    match = re.match(r"([A-Za-z0-9_-]+)(.*)", requirement)
    if match:
        print(f"{match.group(1)}:{match.group(2)}")
')
versions_json=$(nix eval --json --inputs-from "${REPO_ROOT}" "nixpkgs#python3Packages" --apply 'packages: builtins.listToAttrs (builtins.map (name: { inherit name; value = (builtins.getAttr name packages).version or "MISSING"; }) (builtins.filter (name: builtins.elem name ["mcp" "mpmath" "numpy" "pint" "pydantic" "scipy" "sympy" "uncertainties"]) (builtins.attrNames packages)))' || update_error "unable to evaluate nixpkgs dependency versions")

if ! DEPS="${DEPS[*]}" PINS="$pins" VERSIONS_JSON="$versions_json" python3 - <<'PY'
import json
import os
import re


def key(version):
    return tuple(int(part) for part in re.findall(r"\d+", version))


def compare(version, operator, required):
    left, right = key(version), key(required)
    return {
        "==": left == right,
        ">=": left >= right,
        "<=": left <= right,
        ">": left > right,
        "<": left < right,
    }[operator]


def satisfies(version, constraint):
    for clause in constraint.split(","):
        match = re.match(r"(==|>=|<=|>|<)?(.*)", clause)
        operator, required = match.groups()
        if not compare(version, operator or "==", required):
            return False
    return True


pins = dict(line.split(":", 1) for line in os.environ["PINS"].splitlines() if ":" in line)
versions = json.loads(os.environ["VERSIONS_JSON"])
status = 0
for dependency in os.environ["DEPS"].split():
    constraint = pins.get(dependency)
    version = versions.get(dependency, "MISSING")
    if constraint is None or version == "MISSING":
        print(f"drift: {dependency} is not in python3Packages")
        status = 1
        continue
    if dependency in {"mcp", "mpmath"}:
        print(f"note: {dependency} pin is relaxed in default.nix (using nixpkgs {version})")
        continue
    if not satisfies(version, constraint):
        print(f"drift: {dependency} {constraint} -> nixpkgs {version}")
        status = 1
    else:
        print(f"  {dependency}: pyproject {constraint} -> nixpkgs {version}")
raise SystemExit(status)
PY
then
  status=1
fi
exit "${status}"
