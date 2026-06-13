{
  lib,
  stdenv,
  writeShellApplication,
  #### Core packages ####
  bashInteractive,
  uutils-coreutils-noprefix,
  #### Up-to-date version of Codex ####
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
  python3,
  ruff,
  uv,
}: let
  llmAgents = llm-agents.packages.${stdenv.hostPlatform.system}; # llm-agents defined in flake.nix
in
  writeShellApplication {
    name = "codex";

    runtimeInputs = lib.optionals stdenv.isLinux [
      #### Core packages ####
      bashInteractive
      uutils-coreutils-noprefix

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
      python3
      ruff
      uv
    ];

    text =
      if stdenv.isDarwin
      then ''
        exec /usr/bin/open https://chatgpt.com/codex/cloud
      ''
      else ''
        exec ${llmAgents.codex}/bin/codex "$@"
      '';
  }
