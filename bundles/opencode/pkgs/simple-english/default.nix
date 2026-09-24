{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "simple-english";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "AminBlg";
    repo = "SimpleEnglish";
    tag = "v2.1.0";
    hash = "sha256-CPD3x2wcU7INpOpqn0Hg4iY9gB1BAfuHU8e9w//s1sA=";
  };

  # Upstream ships the skill (SKILL.md + references/) under
  # skills/simple-english; everything else in the repo (evals, hooks, plugin
  # manifests) is development tooling that agents never load. Install only
  # the skill. opencode consumes it through programs.opencode.skills (see
  # bundles/opencode/default.nix); the hermes symlink exposes the same files
  # under the hermes share dir, so both layouts resolve to a single copy in
  # the profile.
  #
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/opencode/skills $out/share/hermes/skills
    cp -r skills/simple-english $out/share/opencode/skills/
    ln -s $out/share/opencode/skills/simple-english $out/share/hermes/skills/simple-english
    runHook postInstall
  '';

  meta = {
    description = "ASD-STE100-inspired plain-English writing skill for AI agents";
    homepage = "https://github.com/AminBlg/SimpleEnglish";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
