#!/usr/bin/env bash
# Shared helpers for local package update checks.
# Return codes: 0 = current, 1 = update available, 2 = check failed.

update_error() {
  printf 'update check failed: %s\n' "$1" >&2
  exit 2
}

fetch_url() {
  local url="$1"
  curl -fsSL --retry 3 --connect-timeout 10 --max-time 45 "$url" || update_error "unable to fetch ${url}"
}

fetch_json() {
  fetch_url "$1"
}

latest_tag() {
  local repo="$1"
  fetch_json "https://api.github.com/repos/${repo}/tags?per_page=100" | python3 -c '
import json
import re
import sys

try:
    data = json.load(sys.stdin)
    if not isinstance(data, list):
        raise ValueError("tag response is not a list")
    versions = []
    for item in data:
        name = item.get("name", "")
        match = re.fullmatch(r"(v?\d+(?:\.\d+)+(?:[.-][0-9A-Za-z.-]+)?)", name)
        if match:
            versions.append(match.group(1))
    if not versions:
        raise ValueError("no suitable version tags")
    def key(version):
        return tuple(int(part) if part.isdigit() else part for part in re.split(r"(\d+)", version))
    print(max(versions, key=key))
except Exception as error:
    print(error, file=sys.stderr)
    sys.exit(1)
' || update_error "unable to determine the latest tag for ${repo}"
}

latest_npm_version() {
  local package="$1"
  fetch_json "https://registry.npmjs.org/${package}/latest" | python3 -c '
import json
import sys

try:
    data = json.load(sys.stdin)
    version = data.get("version", "")
    if not version:
        raise ValueError("missing version")
    print(version)
except Exception as error:
    print(error, file=sys.stderr)
    sys.exit(1)
' || update_error "unable to determine the latest npm version for ${package}"
}

latest_commit() {
  local repo="$1"
  fetch_json "https://api.github.com/repos/${repo}/commits?per_page=1" | python3 -c '
import json
import re
import sys

try:
    data = json.load(sys.stdin)
    if not isinstance(data, list) or not data:
        raise ValueError("commit response is empty")
    sha = data[0].get("sha", "")
    if not re.fullmatch(r"[a-f0-9]{40}", sha):
        raise ValueError("invalid commit SHA")
    print(sha)
except Exception as error:
    print(error, file=sys.stderr)
    sys.exit(1)
' || update_error "unable to determine the latest commit for ${repo}"
}

json_dependency_version() {
  local dependency="$1"
  python3 -c '
import json
import sys

dependency = sys.argv[1]
try:
    data = json.load(sys.stdin)
    for section in ("dependencies", "devDependencies", "optionalDependencies"):
        value = data.get(section, {}).get(dependency)
        if value:
            print(value.lstrip("^~<>= "))
            break
    else:
        sys.exit(1)
except Exception:
    sys.exit(1)
' "$dependency"
}

version_at_least() {
  local version="$1"
  local floor="$2"
  local version_parts floor_parts i
  IFS=. read -ra version_parts <<<"$version"
  IFS=. read -ra floor_parts <<<"$floor"
  for i in "${!floor_parts[@]}"; do
    if ((${version_parts[i]:-0} > floor_parts[i])); then
      return 0
    fi
    if ((${version_parts[i]:-0} < floor_parts[i])); then
      return 1
    fi
  done
  return 0
}
