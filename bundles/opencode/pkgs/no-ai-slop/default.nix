{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "no-ai-slop";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "petergyang";
    repo = "no-ai-slop";
    tag = "v1.0.6";
    hash = "sha256-BBAv/PvR6R3psxY2AFNECtXOCqi1NYQ4oSdbCVDMLeI=";
  };

  # At v1.0.6 the skill files sit at the repo root (SKILL.md, eval.md,
  # agents/); the skills/no-ai-slop/ layout only exists on main and should
  # arrive with the next release. Assemble the skill dir from the root files
  # for now, and revisit the copy list on the next tag (see
  # check-updates.sh). SKILL.md references eval.md by name, so both must ship
  # together; agents/openai.yaml is part of upstream's skill folder. The
  # hermes symlink exposes the same files under the hermes share dir, so both
  # layouts resolve to a single copy in the profile.
  #
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/opencode/skills/no-ai-slop $out/share/hermes/skills
    cp SKILL.md eval.md $out/share/opencode/skills/no-ai-slop/
    cp -r agents $out/share/opencode/skills/no-ai-slop/
    ln -s $out/share/opencode/skills/no-ai-slop $out/share/hermes/skills/no-ai-slop
    runHook postInstall
  '';

  meta = {
    description = "Skill that edits AI-slop patterns out of drafts while preserving the writer's voice";
    homepage = "https://github.com/petergyang/no-ai-slop";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
