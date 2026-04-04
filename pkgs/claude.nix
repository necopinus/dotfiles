{
  lib,
  stdenv,
  writeShellApplication,
  #### Core packages ####
  bashInteractive,
  uutils-coreutils-noprefix,
  #### Up-to-date versions of Claude Code and Nono ####
  llm-agents,
  #### Anthropic Sandbox Runtime (part of Claude Code) ####
  ripgrep,
  socat,
  strace, # Only available on Linux
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
  csharp-ls, # Currently broken on macOS ARM
  gopls,
  intelephense,
  jdt-language-server,
  kotlin-language-server,
  lua-language-server,
  pyright,
  rust-analyzer,
  sourcekit-lsp,
  swift,
  typescript,
  typescript-language-server,
}: let
  llmAgents = llm-agents.packages.${stdenv.hostPlatform.system}; # llm-agents defined in flake.nix
in
  writeShellApplication {
    name = "claude";

    runtimeInputs =
      [
        #### Core packages ####
        bashInteractive
        uutils-coreutils-noprefix

        #### Up-to-date versions of Claude Code and Nono ####
        llmAgents.claude-code
        llmAgents.nono

        #### Anthropic Sandbox Runtime (part of Claude Code) ####
        ripgrep
        socat

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
        jdt-language-server
        kotlin-language-server
        lua-language-server
        pyright
        rust-analyzer
        sourcekit-lsp
        swift
        typescript
        typescript-language-server
      ]
      ++ lib.optionals (stdenv.hostPlatform.system != "aarch64-darwin") [
        csharp-ls # Currently broken on macOS ARM
      ]
      ++ lib.optionals stdenv.isLinux [
        strace # Used by the Anthropic Sandbox Runtime (part of Claude Code)
      ];

    # Remove "nounset" from the default list, as we need to test against
    # potentially unset environment variables (CLAUDECODE and
    # NONO_CAP_FILE)
    #
    bashOptions = [
      "errexit"
      "pipefail"
    ];

    text = ''
      # Launch Claude Code (but only if not called recursively to avoid
      # sandboxing the sandbox)
      #
      if [[ -z "$CLAUDECODE" ]] && [[ -z "$NONO_CAP_FILE" ]]; then
        # Resolve symlinks to paths in critical environment variables
        #
        SEP=""
        SANDBOXED_PATH=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_PATH="$SANDBOXED_PATH$SEP$(realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${PATH:+"''${PATH}:"}"

        SEP=""
        SANDBOXED_MANPATH=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_MANPATH="$SANDBOXED_MANPATH$SEP$(realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${MANPATH:+"''${MANPATH}:"}"

        SEP=""
        SANDBOXED_TERMINFO_DIRS=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_TERMINFO_DIRS="$SANDBOXED_TERMINFO_DIRS$SEP$(realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${TERMINFO_DIRS:+"''${TERMINFO_DIRS}:"}"

        SEP=""
        SANDBOXED_XDG_CONFIG_DIRS=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_XDG_CONFIG_DIRS="$SANDBOXED_XDG_CONFIG_DIRS$SEP$(realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${XDG_CONFIG_DIRS:+"''${XDG_CONFIG_DIRS}:"}"

        SEP=""
        SANDBOXED_XDG_DATA_DIRS=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_XDG_DATA_DIRS="$SANDBOXED_XDG_DATA_DIRS$SEP$(realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${XDG_DATA_DIRS:+"''${XDG_DATA_DIRS}:"}"

        SANDBOXED_XDG_CACHE_HOME="$(realpath "''${XDG_CACHE_HOME:-$HOME/.cache}")"
        SANDBOXED_XDG_CONFIG_HOME="$(realpath "''${XDG_CONFIG_HOME:-$HOME/.config}")"
        SANDBOXED_XDG_DATA_HOME="$(realpath "''${XDG_DATA_HOME:-$HOME/.local/share}")"
        SANDBOXED_XDG_STATE_HOME="$(realpath "''${XDG_STATE_HOME:-$HOME/.local/state}")"

        # Launch Claude Code
        #
        # NOTE: We reference the `claude` executable by its full path, as
        # this wrapper is also called `claude`
        #
        # Information about the ENABLE_LSP_TOOL option:
        #
        #   https://karanbansal.in/blog/claude-code-lsp/
        #   https://github.com/anthropics/claude-code/issues/15619
        #
        # On macOS, Claude Code needs to have (temporary) access to
        # launch services in order to login; this is accomplished by
        # passing the `--login` flag
        #
        #   https://nono.sh/docs/cli/clients/claude-code#oauth2-login
        #
        if [[ "$1" == "--login" ]] || [[ "$1" == "-l" ]]; then
          echo "=================================================="
          echo "After logging in, you should exit Claude Code and"
          echo "re-run without the '--login' flag for notmal usage"
          echo "=================================================="
          echo ""
          if [[ "$(uname -s)" == "Darwin" ]]; then
            CLAUDE_COMMAND="${llmAgents.nono}/bin/nono run -p claude-code-local -a . --allow-launch-services -- ${llmAgents.claude-code}/bin/claude /login"
          else
            CLAUDE_COMMAND="${llmAgents.nono}/bin/nono run -p claude-code-local -a . -- ${llmAgents.claude-code}/bin/claude /login"
          fi
        else
          CLAUDE_COMMAND="${llmAgents.nono}/bin/nono run -p claude-code-local -a . -- ${llmAgents.claude-code}/bin/claude --dangerously-skip-permissions $*"
        fi

        # shellcheck disable=SC2046,SC2086
        env -S \
          $([[ -z "$SANDBOXED_MANPATH" ]] && echo -n "-u MANPATH") \
          $([[ -z "$SANDBOXED_TERMINFO_DIRS" ]] && echo -n "-u TERMINFO_DIRS") \
          $([[ -z "$SANDBOXED_XDG_CONFIG_DIRS" ]] && echo -n "-u XDG_CONFIG_DIRS") \
          $([[ -z "$SANDBOXED_XDG_DATA_DIRS" ]] && echo -n "-u XDG_DATA_DIRS") \
          $([[ -n "$SANDBOXED_MANPATH" ]] && echo -n "MANPATH=\"$SANDBOXED_MANPATH\"") \
          $([[ -n "$SANDBOXED_TERMINFO_DIRS" ]] && echo -n "XDG_CONFIG_DIRS=\"$SANDBOXED_TERMINFO_DIRS\"") \
          $([[ -n "$SANDBOXED_XDG_CONFIG_DIRS" ]] && echo -n "XDG_CONFIG_DIRS=\"$SANDBOXED_XDG_CONFIG_DIRS\"") \
          $([[ -n "$SANDBOXED_XDG_DATA_DIRS" ]] && echo -n "XDG_DATA_DIRS=\"$SANDBOXED_XDG_DATA_DIRS\"") \
          CLAUDE_CODE_SHELL=${bashInteractive}/bin/bash \
          ENABLE_LSP_TOOL=1 \
          PATH="$SANDBOXED_PATH" \
          XDG_CACHE_HOME="$SANDBOXED_XDG_CACHE_HOME" \
          XDG_CONFIG_HOME="$SANDBOXED_XDG_CONFIG_HOME" \
          XDG_DATA_HOME="$SANDBOXED_XDG_DATA_HOME" \
          XDG_STATE_HOME="$SANDBOXED_XDG_STATE_HOME" \
          $CLAUDE_COMMAND
      else
        exec ${llmAgents.claude-code}/bin/claude "$@"
      fi
    '';
  }
