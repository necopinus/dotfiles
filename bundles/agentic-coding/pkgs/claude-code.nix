{
  lib,
  pkgs,
  stdenv,
  writeShellApplication,
  #### Up-to-date version of Claude Code ####
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
  #### Language server dependencies ####
  typescript,
  typescript-language-server,
}: let
  llmAgents = llm-agents.packages.${stdenv.hostPlatform.system}; # llm-agents defined in flake.nix
  localPkgs = {
    pyright = pkgs.callPackage ./pyright.nix {};
    pyright-langserver = pkgs.callPackage ./pyright-langserver.nix {};
  };
in
  writeShellApplication {
    name = "claude";

    runtimeInputs = lib.optionals stdenv.isLinux [
      #### Up-to-date version of Claude Code ####
      llmAgents.claude-code

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

      #### Language server dependencies ####
      localPkgs.pyright
      localPkgs.pyright-langserver
      typescript
      typescript-language-server
    ];

    text =
      if stdenv.isDarwin
      then ''
        exec /usr/bin/open https://claude.ai/code
      ''
      else ''
        exec ${llmAgents.claude-code}/bin/claude "$@"
      '';
  }
