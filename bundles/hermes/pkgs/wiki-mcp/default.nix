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
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    sed -i 's/"vitest.config.ts"/"vitest.config.ts", "dist"/' package.json
    sed -i '1i #!/usr/bin/env node' src/index.ts
  '';

  npmDepsHash = "sha256-w20KU6RKQJPB53ilnMjBKkEd9B1P36XRfG/yuvOgzWk=";

  meta = {
    description = "MCP server for Wikipedia and Wikidata APIs";
    homepage = "https://github.com/Mohan-Kumar-Swamynathan/wiki-mcp";
    license = lib.licenses.mit;
    mainProgram = "wiki-mcp";
    platforms = lib.platforms.all;
  };
}
