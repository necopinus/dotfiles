{
  lib,
  pkgs,
  stdenv,
  writeShellApplication,
  #### Core packages ####
  bashInteractive,
  gnugrep,
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
  jdk, # Not actually an LSP, but necessary for JDT.LS to work
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
    kotlin-lsp = pkgs.callPackage ../pkgs/kotlin-lsp.nix {};
  };
in
  writeShellApplication {
    name = "claude";

    runtimeInputs =
      [
        #### Core packages ####
        bashInteractive
        gnugrep
        uutils-coreutils-noprefix

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
        gopls
        intelephense
        jdk # Not actually an LSP, but necessary for JDT.LS to work
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
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        csharp-ls # Not available on macOS ARM
      ];

    text = ''
      # Launch Claude Code, but only in an isolated VM
      #
      if [[ "$(uname -m)" == "Darwin" ]]; then
        open https://claude.ai/code
      elif [[ -d /mnt/internal ]] && [[ -d /mnt/shared ]]; then
        echo "Refusing to launch Claude Code in a non-isolated environment"
        exit 1
      else
        export CLAUDE_CODE_SHELL=${bashInteractive}/bin/bash

        exec ${llmAgents.claude-code}/bin/claude "$@"
      fi
    '';
  }
