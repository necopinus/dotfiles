{
  lib,
  pkgs,
  stdenv,
  writeShellApplication,
  #### Core packages ####
  bashInteractive,
  uutils-coreutils-noprefix,
  #### Up-to-date version of Claude Code ####
  llm-agents,
  #### Anthropic Sandbox Runtime (part of Claude Code) ####
  ripgrep,
  socat,
  strace,
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
  #### Language Servers ####
  clang-tools,
  csharp-ls, # Not available on macOS ARM
  gopls,
  intelephense,
  jdt-language-server,
  lua-language-server,
  pyright,
  ruby-lsp,
  rust-analyzer,
  sourcekit-lsp,
  swift,
  typescript,
  typescript-language-server,
}: let
  llmAgents = llm-agents.packages.${stdenv.hostPlatform.system}; # llm-agents defined in flake.nix

  # Wrap kotlin-language-server so Claude can find it
  #
  localPkgs = {
    kotlin-lsp = pkgs.callPackage ./kotlin-lsp.nix {};
  };
in
  writeShellApplication {
    name = "claude";

    runtimeInputs =
      [
        #### Core packages ####
        uutils-coreutils-noprefix
      ]
      ++ lib.optionals stdenv.isLinux [
        #### Core packages ####
        bashInteractive

        #### Up-to-date version of Claude Code ####
        llmAgents.claude-code

        #### Anthropic Sandbox Runtime (part of Claude Code) ####
        ripgrep
        socat
        strace

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

        #### Language Servers ####
        clang-tools
        csharp-ls # Not available on macOS ARM
        gopls
        intelephense
        jdt-language-server
        localPkgs.kotlin-lsp # Wraps kotlin-language-server so Claude can find it
        lua-language-server
        pyright
        ruby-lsp
        rust-analyzer
        sourcekit-lsp
        swift
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
