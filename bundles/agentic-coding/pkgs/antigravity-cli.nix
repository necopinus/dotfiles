{
  lib,
  stdenv,
  writeShellApplication,
  #### Up-to-date version of Antigravity ####
  llm-agents,
  #### Bash ####
  shellcheck,
  shfmt,
  #### JavaScript / Typescript ####
  nodejs,
  pnpm,
  prettier,
  rslint,
  #### Python ####
  ruff,
  uv,
}: let
  llmAgents = llm-agents.packages.${stdenv.hostPlatform.system}; # llm-agents defined in flake.nix
in
  writeShellApplication {
    name = "agy";

    runtimeInputs = lib.optionals stdenv.isLinux [
      #### Up-to-date version of Codex ####
      llmAgents.codex

      #### Bash ####
      shellcheck
      shfmt

      #### JavaScript / Typescript ####
      nodejs
      pnpm
      prettier
      rslint

      #### Python ####
      ruff
      uv
    ];

    text =
      if stdenv.isDarwin
      then ''
        exec /usr/bin/open https://aistudio.google.com/apps
      ''
      else ''
        exec ${llmAgents.antigravity-cli}/bin/agy "$@"
      '';
  }
