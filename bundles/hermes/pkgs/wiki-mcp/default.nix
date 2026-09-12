{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage {
  pname = "wiki-mcp";
  version = "1.0.0-unstable-2026-04-12";

  src = fetchFromGitHub {
    owner = "Mohan-Kumar-Swamynathan";
    repo = "wiki-mcp";
    rev = "f38566cedecc16392ffdcdb192fae5a7c82de167";
    hash = "sha256-Tvgo4U1GqprCOHNPfIHZUoRj6zpz46BYQomqhE8aKyw=";
  };

  # Upstream ships no lockfile, and the published npm tarball omits `dist`
  # entirely (its `files` allowlist excludes it), so both the lockfile and the
  # build have to be fixed up locally.
  #
  # 1. Vendor a package-lock.json generated from the pinned commit with
  #    `npm install --package-lock-only`, so npmDepsHash stays reproducible.
  #
  # 2. Add `dist` to package.json `files`, otherwise buildNpmPackage's
  #    install phase (which copies only what `npm pack` would include)
  #    produces a package with no compiled code.
  #
  # 3. Inject a shebang into the entry point so the bin npm wires up is
  #    actually executable; esbuild preserves it through the tsup build.
  #
  # Security patches against the pinned commit. Each names the advisory it
  # fixes and the condition that makes it obsolete; check both on every
  # upstream dependency bump (see check-updates.sh):
  #
  # - 0001-security-readability-0.6.0.patch:
  #   @mozilla/readability ^0.5.0 -> ^0.6.0 (CVE-2025-2792);
  #   drop once upstream requires @mozilla/readability >= 0.6.0.
  #
  # - 0002-security-vitest4-tsup8-esbuild-override.patch:
  #   vitest ^2.0.0 -> ^4.1.11 (CVE-2026-47429, CVE-2026-84373),
  #   tsup ^8.0.0 -> ^8.5.1 (fixes the vulnerable vite and esbuild chains:
  #   CVE-2026-53571, CVE-2026-53632, GHSA-67mh-4wv8-2f99),
  #   plus an npm overrides entry forcing esbuild >= 0.28.1
  #   (GHSA-g7r4-m6w7-qqqr, a build-time-only concern);
  #   drop once upstream requires vitest >= 4.1.11 and tsup >= 8.5.1 with
  #   esbuild >= 0.28.1 reachable in its dependency tree.
  #
  # The patches touch only package.json; the vendored lockfile below is
  # regenerated from the patched manifest.
  patches = [
    ./0001-security-readability-0.6.0.patch
    ./0002-security-vitest4-tsup8-esbuild-override.patch
  ];

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    sed -i 's/"vitest.config.ts"/"vitest.config.ts", "dist"/' package.json
    sed -i '1i #!/usr/bin/env node' src/index.ts
  '';

  npmDepsHash = "sha256-Od7Yc8wMJtP8QScQT6N4W3OMfCf/cvfl77BrOfi1HnE=";

  meta = {
    description = "MCP server for Wikipedia and Wikidata APIs";
    homepage = "https://github.com/Mohan-Kumar-Swamynathan/wiki-mcp";
    license = lib.licenses.mit;
    mainProgram = "wiki-mcp";
    platforms = lib.platforms.all;
  };
}
