{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_10,
  nodejs,
  makeWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mcplogic";
  version = "1.1.1-unstable-2026-05-15";

  src = fetchFromGitHub {
    owner = "autonull";
    repo = "mcplogic";
    rev = "3de2627d2d4608fd3561fe6dd41f2ad3cc3c88b2";
    hash = "sha256-Da27C12SaS80mV1BfMjO8kEL/NQRTTv2nZtpq10aDqE=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm_10
    pnpmConfigHook
    makeWrapper
  ];

  # Upstream locks its deps with pnpm (lockfileVersion 9.0, native to pnpm 10),
  # so use the same toolchain rather than a vendored npm lockfile. The WASM
  # engines (z3-solver, clingo-wasm) ship as plain npm packages, so no native
  # compilation is needed.
  #
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 4;
    hash = "sha256-3+cJUV6Uaw3t+Nnj4NcIwMnNTojGOuX6hIcqUdRcH4s=";
  };

  buildPhase = ''
    runHook preBuild
    pnpm run build
    runHook postBuild
  '';

  # Keep the pnpm layout (relative symlinks into node_modules/.pnpm) intact
  # via `cp -a`; dev dependencies are pruned first. Upstream exposes the MCP
  # server as `node dist/index.js` with no bin entry, while the npm bin
  # `mcplogic` is a CLI (check/prove/model/repl), so wrap both explicitly.
  #
  installPhase = ''
    runHook preInstall
    pnpm prune --prod
    mkdir -p $out/lib/mcplogic
    cp -a dist package.json node_modules $out/lib/mcplogic/
    makeWrapper ${nodejs}/bin/node $out/bin/mcplogic-mcp \
      --add-flags "$out/lib/mcplogic/dist/index.js"
    makeWrapper ${nodejs}/bin/node $out/bin/mcplogic \
      --add-flags "$out/lib/mcplogic/dist/cli.js"
    runHook postInstall
  '';

  meta = {
    description = "MCP server for first-order logic reasoning (Z3, Clingo, Tau-Prolog, SAT)";
    homepage = "https://github.com/autonull/mcplogic";
    license = lib.licenses.mit;
    mainProgram = "mcplogic-mcp";
    platforms = lib.platforms.all;
  };
})
