{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
  python3,
}:
buildNpmPackage {
  pname = "context-mode";
  version = "1.0.169";

  src = fetchFromGitHub {
    owner = "mksglu";
    repo = "context-mode";
    tag = "v1.0.169";
    hash = "sha256-1pV56ZB2aqod+C0kb5myuiWLAJ7+opiaurwZZ3BGKYk=";
  };

  # Packaging notes:
  #
  # 1. Upstream commits a bun.lock but declares pnpm as its packageManager,
  #    so there is no npm-usable lockfile. Vendor a package-lock.json
  #    generated from the pinned tag with `npm install --package-lock-only`
  #    so npmDepsHash stays reproducible (see check-updates.sh).
  #
  # 2. The esbuild bundles (server.bundle.mjs, cli.bundle.mjs,
  #    hooks/*.bundle.mjs) are checked into the repo, so no tsc/esbuild run
  #    is needed. dontNpmBuild skips `npm run build`, which would also run
  #    upstream's bundle/drift asserts.
  #
  # 3. --ignore-scripts keeps upstream's postinstall.mjs (Claude-Code
  #    self-heal writes plus a hard-fail on Node < 22.5) out of the build.
  #    better-sqlite3's own install script is then run explicitly in
  #    preBuild so the native addon compiles against the nixpkgs Node ABI;
  #    offline, prebuild-install fails fast and node-gyp falls back to the
  #    bundled sqlite amalgamation.
  #
  # 4. Runtime layout: the MCP entry point start.mjs statically imports
  #    hooks/ensure-deps.mjs, lazily imports other hooks/ and scripts/
  #    helpers (all best-effort), and its boot gate
  #    (scripts/plugin-cache-integrity.mjs) requires the two root bundles,
  #    hooks/security.bundle.mjs, and the five hook entry points. Ship the
  #    whole hooks/ and scripts/ trees rather than chase that drift.
  #
  # 5. better-sqlite3, turndown, turndown-plugin-gfm, and
  #    @mixmark-io/domino are esbuild externals resolved from node_modules
  #    at runtime. Shipping them stops start.mjs from attempting (failing,
  #    read-only) npm installs on every boot. On Node >= 22.5 the server
  #    actually runs on node:sqlite (probed for FTS5 at load), so
  #    better-sqlite3 stays dormant unless that probe fails.
  #
  # 6. skills/ lands in share/opencode/skills for programs.opencode.skills.
  #    Unlike the other skill packages there is deliberately NO
  #    share/hermes/skills symlink: this one is opencode-only. The `.ignore`
  #    file is a Pi-skill-loader hint, not a skill, so it is dropped.
  #
  # Local patch:
  #
  # - 0001-stability-skip-better-sqlite3-probe-on-modern-node.patch:
  #   ensureNativeCompat's in-process probe dlopens the better-sqlite3 addon
  #   even on Node >= 22.5, where loadDatabase always picks node:sqlite and
  #   the addon is never used. On nixpkgs Node builds the probe's native
  #   teardown can abort the whole MCP server (upstream #564 class). Skip
  #   the probe/heal on such runtimes; drop this patch once upstream gates
  #   the probe on the fallback actually being reachable.
  #
  # - 0002-security-esbuild-0.28.2.patch:
  #   esbuild ^0.27.3 -> ^0.28.2 (GHSA-g7r4-m6w7-qqqr). esbuild is a
  #   devDependency that is never executed here (the build uses upstream's
  #   prebuilt bundles and devDependencies are pruned before install), so
  #   this silences lockfile scanners rather than closing live exposure.
  #   Drop once upstream requires esbuild >= 0.28.2.
  #
  # The vendored package-lock.json below is regenerated from the patched
  # manifest (see check-updates.sh).
  #
  patches = [
    ./0001-stability-skip-better-sqlite3-probe-on-modern-node.patch
    ./0002-security-esbuild-0.28.2.patch
  ];

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    chmod +w package-lock.json
  '';

  npmDepsHash = "sha256-SssYg7qKAhFC+p0/vnZfxisRCPoaboGA7CC+JxmKY3Y=";
  npmFlags = ["--ignore-scripts"];

  nativeBuildInputs = [
    makeWrapper
    python3 # node-gyp
  ];

  dontNpmBuild = true;
  dontNpmInstall = true;

  preBuild = ''
    npm rebuild better-sqlite3 --ignore-scripts=false
  '';

  # Drop devDependencies (esbuild, typescript, vitest, ...) so only the
  # runtime externals ship in node_modules.
  #
  postBuild = ''
    npm prune --omit=dev --ignore-scripts
    # npm prune leaves empty @scope directories behind.
    find node_modules -type d -empty -delete
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/context-mode $out/share/opencode/skills

    cp server.bundle.mjs cli.bundle.mjs start.mjs package.json README.md LICENSE \
      $out/lib/context-mode/
    cp -r hooks scripts node_modules $out/lib/context-mode/

    cp -r skills/. $out/share/opencode/skills/
    rm -f $out/share/opencode/skills/.ignore

    # CLI (`context-mode doctor`, upgrades, stats) and the stdio MCP server
    # the client launches.
    makeWrapper ${nodejs}/bin/node $out/bin/context-mode \
      --add-flags "$out/lib/context-mode/cli.bundle.mjs"
    makeWrapper ${nodejs}/bin/node $out/bin/context-mode-mcp \
      --add-flags "$out/lib/context-mode/start.mjs"

    runHook postInstall
  '';

  meta = {
    description = "MCP server that sandboxes tool output and persists session memory, with companion skills";
    homepage = "https://github.com/mksglu/context-mode";
    license = lib.licenses.elastic20;
    mainProgram = "context-mode";
    platforms = lib.platforms.all;
  };
}
