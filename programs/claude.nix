{
  config,
  pkgs,
  lib,
  ...
}: let
  claudeInChrome = {
    extensionId = "fcoeoabgfenejglbffodgkkbkcdhcgfn";
    nativeHostName = "com.anthropic.claude_code_browser_extension";
    nativeHostConfig = ''
      {
        "name": "${claudeInChrome.nativeHostName}",
        "description": "Claude Code Browser Extension Native Host",
        "path": "${config.home.homeDirectory}/.claude/chrome/chrome-native-host",
        "type": "stdio",
        "allowed_origins": [
          "chrome-extension://${claudeInChrome.extensionId}/",
        ]
      }
    '';
  };
in {
  #################### Various helper packages ####################

  programs.uv.enable = true;
  home.packages = with pkgs;
    [
      nono

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
    ++ pkgs.lib.optionals (pkgs.stdenv.hostPlatform.system != "aarch64-darwin") [
      csharp-ls # Currently broken on macOS ARM
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      strace # Used by the Anthropic Sandbox Runtime (part of Claude Code)
    ];

  #################### Claude Code ####################

  programs.claude-code = {
    enable = true;

    # IMPORTANT: You cannot use both nono and Claude's built-in sandboxing at
    # the same time!
    #
    settings = {
      outputStyle = "Explanatory";
      alwaysThinkingEnabled = true;
      skipDangerousModePermissionPrompt = true;
      env = {
        "ENABLE_LSP_TOOL" = "1";
      };
      "enabledPlugins" =
        {
          "clangd-lsp@claude-plugins-official" = true;
          "gopls-lsp@claude-plugins-official" = true;
          "jdtls-lsp@claude-plugins-official" = true;
          "kotlin-lsp@claude-plugins-official" = true;
          "lua-lsp@claude-plugins-official" = true;
          "php-lsp@claude-plugins-official" = true;
          "pyright-lsp@claude-plugins-official" = true;
          "rust-analyzer-lsp@claude-plugins-official" = true;
          "swift-lsp@claude-plugins-official" = true;
          "typescript-lsp@claude-plugins-official" = true;
        }
        // lib.attrsets.optionalAttrs (pkgs.stdenv.hostPlatform.system != "aarch64-darwin") {
          "csharp-lsp@claude-plugins-official" = true; # LSP currently broken on macOS ARM
        };
      hooks = {
        PostToolUseFailure = [
          {
            hooks = [
              {
                command = "${config.home.homeDirectory}/.claude/hooks/nono-hook.sh";
                type = "command";
              }
            ];
            matcher = "Read|Write|Edit|Bash";
          }
        ];
      };
    };
  };

  # Make sure that Claude Code always uses bash for its shell
  #
  home.sessionVariables.CLAUDE_CODE_SHELL = "${pkgs.bashInteractive}/bin/bash";

  # Force LSP service on (still requires related plugins to be
  # installed)
  #
  #   https://karanbansal.in/blog/claude-code-lsp/
  #   https://github.com/anthropics/claude-code/issues/15619
  #
  home.sessionVariables.ENABLE_LSP_TOOL = "1";
  home.file.".claude/CLAUDE.md".source = ../artifacts/claude/CLAUDE.md;

  # Claude expects a kotlin-lsp binary, but Nixpkgs provides
  # kotlin-language-server
  #
  home.file.".local/bin/kotlin-lsp".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.kotlin-language-server}/bin/kotlin-language-server";

  # Use Claude in Chrome with Chromium
  #
  programs.chromium.extensions = [
    {id = "${claudeInChrome.extensionId}";} # Claude for Chrome
  ];
  home.file."Library/Application Support/Chromium/Default/Extensions/.keep" = {
    enable = pkgs.stdenv.isDarwin && config.programs.chromium.enable;
    text = "";
  };
  home.file."Library/Application Support/Chromium/NativeMessagingHosts/${claudeInChrome.nativeHostName}.json" = {
    enable = pkgs.stdenv.isDarwin && config.programs.chromium.enable;
    text = "${claudeInChrome.nativeHostConfig}";
  };
  home.file."Library/Application Support/Google/Chrome/Default/Extensions" = {
    enable = pkgs.stdenv.isDarwin && config.programs.chromium.enable;
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/Application Support/Chromium/Default/Extensions";
  };
  home.file."Library/Application Support/Google/Chrome/NativeMessagingHosts" = {
    enable = pkgs.stdenv.isDarwin && config.programs.chromium.enable;
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/Application Support/Chromium/NativeMessagingHosts";
  };
  xdg.configFile."chromium/Default/Extensions/.keep" = {
    enable = pkgs.stdenv.isLinux && config.programs.chromium.enable;
    text = "";
  };
  xdg.configFile."chromium/NativeMessagingHosts/${claudeInChrome.nativeHostName}.json" = {
    enable = pkgs.stdenv.isLinux && config.programs.chromium.enable;
    text = "${claudeInChrome.nativeHostConfig}";
  };
  xdg.configFile."google-chrome/Default/Extensions" = {
    enable = pkgs.stdenv.isLinux && config.programs.chromium.enable;
    source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/chromium/Default/Extensions";
  };
  xdg.configFile."google-chrome/NativeMessagingHosts" = {
    enable = pkgs.stdenv.isLinux && config.programs.chromium.enable;
    source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/chromium/NativeMessagingHosts";
  };

  # Wrap Claude Code in the Nono sandbox, but only if not called
  # recursively (to avoid sandboxing the sandbox)
  #
  # Note that we have to resolve (potentially) critical paths in the
  # environment, as nono will not follow home-manager's symlinks
  # without making all of $HOME readable
  #
  xdg.configFile."bash/rc.d/claude.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      function claude {
        CLAUDE_CODE_EXEC="$(${pkgs.uutils-coreutils-noprefix}/bin/realpath "$(${pkgs.which}/bin/which claude)")"

        if [[ "$CLAUDE_CODE_EXEC" == */scripts/claude ]] || [[ -n "$CLAUDECODE" ]] || [[ -n "$NONO_CAP_FILE" ]]; then
          "$CLAUDE_CODE_EXEC" "$@"
        else
          nono run --profile claude-code --allow . -- "$CLAUDE_CODE_EXEC" --dangerously-skip-permissions "$@"
        fi
      }
    '';
  };
  xdg.configFile."zsh/rc.d/claude.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      function claude {
        CLAUDE_CODE_EXEC="$(${pkgs.uutils-coreutils-noprefix}/bin/realpath "$(whence -p claude)")"

        if [[ "$CLAUDE_CODE_EXEC" == */scripts/claude ]] || [[ -n "$CLAUDECODE" ]] || [[ -n "$NONO_CAP_FILE" ]]; then
          "$CLAUDE_CODE_EXEC" "$@"
        else
          nono run --profile claude-code --allow . -- "$CLAUDE_CODE_EXEC" --dangerously-skip-permissions "$@"
        fi
      }
    '';
  };
  programs.fish.functions."claude" = ''
    set CLAUDE_CODE_EXEC $(${pkgs.uutils-coreutils-noprefix}/bin/realpath $(${pkgs.which}/bin/which claude))

    if string match "*/scripts/claude" $CLAUDE_CODE_EXEC &> /dev/null; or test -n "$CLAUDECODE"; or test -n "$NONO_CAP_FILE"
      $CLAUDE_CODE_EXEC $argv
    else
      nono run --profile claude-code --allow . -- $CLAUDE_CODE_EXEC --dangerously-skip-permissions $argv
    end
  '';

  #################### Nono ####################

  # Nono doesn't follow symlinks unless all *parent* directories are
  # readable; since this is undesirable, we wrap nono in all shells
  # with a function that modifes the environment so that variables
  # representing paths already fully resolved
  #
  xdg.configFile."bash/rc.d/nono.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      function nono {
        SEP=""
        SANDBOXED_PATH=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_PATH="$SANDBOXED_PATH$SEP$(${pkgs.uutils-coreutils-noprefix}/bin/realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${PATH:+"''${PATH}:"}"

        SEP=""
        SANDBOXED_MANPATH=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_MANPATH="$SANDBOXED_MANPATH$SEP$(${pkgs.uutils-coreutils-noprefix}/bin/realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${MANPATH:+"''${MANPATH}:"}"

        SEP=""
        SANDBOXED_TERMINFO_DIRS=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_TERMINFO_DIRS="$SANDBOXED_TERMINFO_DIRS$SEP$(${pkgs.uutils-coreutils-noprefix}/bin/realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${TERMINFO_DIRS:+"''${TERMINFO_DIRS}:"}"

        SEP=""
        SANDBOXED_XDG_CONFIG_DIRS=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_XDG_CONFIG_DIRS="$SANDBOXED_XDG_CONFIG_DIRS$SEP$(${pkgs.uutils-coreutils-noprefix}/bin/realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${XDG_CONFIG_DIRS:+"''${XDG_CONFIG_DIRS}:"}"

        SEP=""
        SANDBOXED_XDG_DATA_DIRS=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_XDG_DATA_DIRS="$SANDBOXED_XDG_DATA_DIRS$SEP$(${pkgs.uutils-coreutils-noprefix}/bin/realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${XDG_DATA_DIRS:+"''${XDG_DATA_DIRS}:"}"

        SANDBOXED_XDG_CACHE_HOME="$(realpath "''${XDG_CACHE_HOME:-$HOME/.cache}")"
        SANDBOXED_XDG_CONFIG_HOME="$(realpath "''${XDG_CONFIG_HOME:-$HOME/.config}")"
        SANDBOXED_XDG_DATA_HOME="$(realpath "''${XDG_DATA_HOME:-$HOME/.local/share}")"
        SANDBOXED_XDG_STATE_HOME="$(realpath "''${XDG_STATE_HOME:-$HOME/.local/state}")"

        export SANDBOXED_PATH SANDBOXED_MANPATH SANDBOXED_TERMINFO_DIRS SANDBOXED_XDG_CONFIG_DIRS SANDBOXED_XDG_DATA_DIRS SANDBOXED_XDG_CACHE_HOME SANDBOXED_XDG_CONFIG_HOME SANDBOXED_XDG_DATA_HOME SANDBOXED_XDG_STATE_HOME

        eval ${pkgs.uutils-coreutils-noprefix}/bin/env -S \
          $([[ -z "$SANDBOXED_MANPATH" ]] && echo -n "-u MANPATH") \
          $([[ -z "$SANDBOXED_TERMINFO_DIRS" ]] && echo -n "-u TERMINFO_DIRS") \
          $([[ -z "$SANDBOXED_XDG_CONFIG_DIRS" ]] && echo -n "-u XDG_CONFIG_DIRS") \
          $([[ -z "$SANDBOXED_XDG_DATA_DIRS" ]] && echo -n "-u XDG_DATA_DIRS") \
          $([[ -n "$SANDBOXED_MANPATH" ]] && echo -n "MANPATH=\"$SANDBOXED_MANPATH\"") \
          $([[ -n "$SANDBOXED_TERMINFO_DIRS" ]] && echo -n "XDG_CONFIG_DIRS=\"$SANDBOXED_TERMINFO_DIRS\"") \
          $([[ -n "$SANDBOXED_XDG_CONFIG_DIRS" ]] && echo -n "XDG_CONFIG_DIRS=\"$SANDBOXED_XDG_CONFIG_DIRS\"") \
          $([[ -n "$SANDBOXED_XDG_DATA_DIRS" ]] && echo -n "XDG_DATA_DIRS=\"$SANDBOXED_XDG_DATA_DIRS\"") \
          PATH="$SANDBOXED_PATH" \
          XDG_CACHE_HOME="$SANDBOXED_XDG_CACHE_HOME" \
          XDG_CONFIG_HOME="$SANDBOXED_XDG_CONFIG_HOME" \
          XDG_DATA_HOME="$SANDBOXED_XDG_DATA_HOME" \
          XDG_STATE_HOME="$SANDBOXED_XDG_STATE_HOME" \
          ${pkgs.nono}/bin/nono "$@"

        unset SANDBOXED_PATH SANDBOXED_MANPATH SANDBOXED_TERMINFO_DIRS SANDBOXED_XDG_CONFIG_DIRS SANDBOXED_XDG_DATA_DIRS SANDBOXED_XDG_CACHE_HOME SANDBOXED_XDG_CONFIG_HOME SANDBOXED_XDG_DATA_HOME SANDBOXED_XDG_STATE_HOME
      }
    '';
  };
  xdg.configFile."zsh/rc.d/nono.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      function nono {
        SEP=""
        SANDBOXED_PATH=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_PATH="$SANDBOXED_PATH$SEP$(${pkgs.uutils-coreutils-noprefix}/bin/realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${PATH:+"''${PATH}:"}"

        SEP=""
        SANDBOXED_MANPATH=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_MANPATH="$SANDBOXED_MANPATH$SEP$(${pkgs.uutils-coreutils-noprefix}/bin/realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${MANPATH:+"''${MANPATH}:"}"

        SEP=""
        SANDBOXED_TERMINFO_DIRS=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_TERMINFO_DIRS="$SANDBOXED_TERMINFO_DIRS$SEP$(${pkgs.uutils-coreutils-noprefix}/bin/realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${TERMINFO_DIRS:+"''${TERMINFO_DIRS}:"}"

        SEP=""
        SANDBOXED_XDG_CONFIG_DIRS=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_XDG_CONFIG_DIRS="$SANDBOXED_XDG_CONFIG_DIRS$SEP$(${pkgs.uutils-coreutils-noprefix}/bin/realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${XDG_CONFIG_DIRS:+"''${XDG_CONFIG_DIRS}:"}"

        SEP=""
        SANDBOXED_XDG_DATA_DIRS=""
        while IFS=: read -d: -r DIR; do
          if [[ -d "$DIR" ]]; then
            SANDBOXED_XDG_DATA_DIRS="$SANDBOXED_XDG_DATA_DIRS$SEP$(${pkgs.uutils-coreutils-noprefix}/bin/realpath "$DIR")"
            if [[ -z "$SEP" ]]; then
              SEP=":"
            fi
          fi
        done <<<"''${XDG_DATA_DIRS:+"''${XDG_DATA_DIRS}:"}"

        SANDBOXED_XDG_CACHE_HOME="$(realpath "''${XDG_CACHE_HOME:-$HOME/.cache}")"
        SANDBOXED_XDG_CONFIG_HOME="$(realpath "''${XDG_CONFIG_HOME:-$HOME/.config}")"
        SANDBOXED_XDG_DATA_HOME="$(realpath "''${XDG_DATA_HOME:-$HOME/.local/share}")"
        SANDBOXED_XDG_STATE_HOME="$(realpath "''${XDG_STATE_HOME:-$HOME/.local/state}")"

        export SANDBOXED_PATH SANDBOXED_MANPATH SANDBOXED_TERMINFO_DIRS SANDBOXED_XDG_CONFIG_DIRS SANDBOXED_XDG_DATA_DIRS SANDBOXED_XDG_CACHE_HOME SANDBOXED_XDG_CONFIG_HOME SANDBOXED_XDG_DATA_HOME SANDBOXED_XDG_STATE_HOME

        eval ${pkgs.uutils-coreutils-noprefix}/bin/env -S \
          $([[ -z "$SANDBOXED_MANPATH" ]] && echo -n "-u MANPATH") \
          $([[ -z "$SANDBOXED_TERMINFO_DIRS" ]] && echo -n "-u TERMINFO_DIRS") \
          $([[ -z "$SANDBOXED_XDG_CONFIG_DIRS" ]] && echo -n "-u XDG_CONFIG_DIRS") \
          $([[ -z "$SANDBOXED_XDG_DATA_DIRS" ]] && echo -n "-u XDG_DATA_DIRS") \
          $([[ -n "$SANDBOXED_MANPATH" ]] && echo -n "MANPATH=\"$SANDBOXED_MANPATH\"") \
          $([[ -n "$SANDBOXED_TERMINFO_DIRS" ]] && echo -n "XDG_CONFIG_DIRS=\"$SANDBOXED_TERMINFO_DIRS\"") \
          $([[ -n "$SANDBOXED_XDG_CONFIG_DIRS" ]] && echo -n "XDG_CONFIG_DIRS=\"$SANDBOXED_XDG_CONFIG_DIRS\"") \
          $([[ -n "$SANDBOXED_XDG_DATA_DIRS" ]] && echo -n "XDG_DATA_DIRS=\"$SANDBOXED_XDG_DATA_DIRS\"") \
          PATH="$SANDBOXED_PATH" \
          XDG_CACHE_HOME="$SANDBOXED_XDG_CACHE_HOME" \
          XDG_CONFIG_HOME="$SANDBOXED_XDG_CONFIG_HOME" \
          XDG_DATA_HOME="$SANDBOXED_XDG_DATA_HOME" \
          XDG_STATE_HOME="$SANDBOXED_XDG_STATE_HOME" \
          ${pkgs.nono}/bin/nono "$@"

        unset SANDBOXED_PATH SANDBOXED_MANPATH SANDBOXED_TERMINFO_DIRS SANDBOXED_XDG_CONFIG_DIRS SANDBOXED_XDG_DATA_DIRS SANDBOXED_XDG_CACHE_HOME SANDBOXED_XDG_CONFIG_HOME SANDBOXED_XDG_DATA_HOME SANDBOXED_XDG_STATE_HOME
      }
    '';
  };
  programs.fish.functions."nono" = ''
    set SEP ""
    set SANDBOXED_PATH ""
    for DIR in $(string split : $(string join : $PATH))
      if test -d $DIR
        set -x SANDBOXED_PATH "$SANDBOXED_PATH$SEP$(${pkgs.uutils-coreutils-noprefix}/bin/realpath $DIR)"
        if test -z "$SEP"
          set SEP ":"
        end
      end
    end

    set SEP ""
    set SANDBOXED_MANPATH ""
    for DIR in $(string split : $MANPATH)
      if test -d $DIR
        set -x SANDBOXED_MANPATH "$SANDBOXED_MANPATH$SEP$(${pkgs.uutils-coreutils-noprefix}/bin/realpath $DIR)"
        if test -z "$SEP"
          set SEP ":"
        end
      end
    end

    set SEP ""
    set SANDBOXED_TERMINFO_DIRS ""
    for DIR in $(string split : $TERMINFO_DIRS)
      if test -d $DIR
        set -x SANDBOXED_TERMINFO_DIRS "$SANDBOXED_TERMINFO_DIRS$SEP$(${pkgs.uutils-coreutils-noprefix}/bin/realpath $DIR)"
        if test -z "$SEP"
          set SEP ":"
        end
      end
    end

    set SEP ""
    set SANDBOXED_XDG_CONFIG_DIRS ""
    for DIR in $(string split : $XDG_CONFIG_DIRS)
      if test -d $DIR
        set -x SANDBOXED_XDG_CONFIG_DIRS "$SANDBOXED_XDG_CONFIG_DIRS$SEP$(${pkgs.uutils-coreutils-noprefix}/bin/realpath $DIR)"
        if test -z "$SEP"
          set SEP ":"
        end
      end
    end

    set SEP ""
    set SANDBOXED_XDG_DATA_DIRS ""
    for DIR in $(string split : $XDG_DATA_DIRS)
      if test -d $DIR
        set -x SANDBOXED_XDG_DATA_DIRS "$SANDBOXED_XDG_DATA_DIRS$SEP$(${pkgs.uutils-coreutils-noprefix}/bin/realpath $DIR)"
        if test -z "$SEP"
          set SEP ":"
        end
      end
    end

    if test -z "$XDG_CACHE_HOME"
      set -x SANDBOXED_XDG_CACHE_HOME "$(realpath $HOME/.cache)"
    else
      set -x SANDBOXED_XDG_CACHE_HOME "$(realpath $XDG_CACHE_HOME)"
    end
    if test -z "$XDG_CONFIG_HOME"
      set -x SANDBOXED_XDG_CONFIG_HOME "$(realpath $HOME/.config)"
    else
      set -x SANDBOXED_XDG_CONFIG_HOME "$(realpath $XDG_CONFIG_HOME)"
    end
    if test -z "$XDG_DATA_HOME"
      set -x SANDBOXED_XDG_DATA_HOME "$(realpath $HOME/.local/share)"
    else
      set -x SANDBOXED_XDG_DATA_HOME "$(realpath $XDG_DATA_HOME)"
    end
    if test -z "$XDG_DATA_HOME"
      set -x SANDBOXED_XDG_STATE_HOME "$(realpath $HOME/.local/state)"
    else
      set -x SANDBOXED_XDG_STATE_HOME "$(realpath $XDG_STATE_HOME)"
    end

    eval ${pkgs.uutils-coreutils-noprefix}/bin/env -S \
      (test -z "$SANDBOXED_MANPATH" && echo -n "-u MANPATH") \
      (test -z "$SANDBOXED_TERMINFO_DIRS" && echo -n "-u TERMINFO_DIRS") \
      (test -z "$SANDBOXED_XDG_CONFIG_DIRS" && echo -n "-u XDG_CONFIG_DIRS") \
      (test -z "$SANDBOXED_XDG_DATA_DIRS" && echo -n "-u XDG_DATA_DIRS") \
      (test -n "$SANDBOXED_MANPATH" && echo -n "MANPATH=\"$SANDBOXED_MANPATH\"") \
      (test -n "$SANDBOXED_TERMINFO_DIRS" && echo -n "TERMINFO_DIRS=\"$SANDBOXED_TERMINFO_DIRS\"") \
      (test -n "$SANDBOXED_XDG_CONFIG_DIRS" && echo -n "XDG_CONFIG_DIRS=\"$SANDBOXED_XDG_CONFIG_DIRS\"") \
      (test -n "$SANDBOXED_XDG_DATA_DIRS" && echo -n "XDG_DATA_DIRS=\"$SANDBOXED_XDG_DATA_DIRS\"") \
      PATH="$SANDBOXED_PATH" \
      XDG_CACHE_HOME="$SANDBOXED_XDG_CACHE_HOME" \
      XDG_CONFIG_HOME="$SANDBOXED_XDG_CONFIG_HOME" \
      XDG_DATA_HOME="$SANDBOXED_XDG_DATA_HOME" \
      XDG_STATE_HOME="$SANDBOXED_XDG_STATE_HOME" \
      ${pkgs.nono}/bin/nono $argv

    set -e SANDBOXED_PATH
    set -e SANDBOXED_MANPATH
    set -e SANDBOXED_TERMINFO_DIRS
    set -e SANDBOXED_XDG_CONFIG_DIRS
    set -e SANDBOXED_XDG_DATA_DIRS
    set -e SANDBOXED_XDG_CACHE_HOME
    set -e SANDBOXED_XDG_CONFIG_HOME
    set -e SANDBOXED_XDG_DATA_HOME
    set -e SANDBOXED_XDG_STATE_HOME
  '';

  # Check for SANDBOXED_* paths and replace computed paths with these
  # values if found (this works around the chicken-and-egg problem
  # where paths passed in during sandboxing may be wiped out during
  # init and cannot be reconstructed from within the sandbox due to
  # restrictions)
  #
  # IMPORTANT: Keep this block in sync with the SANDBOXED_* paths
  # set by the `nono` wrapper functions above!
  #
  # NOTE: This must happen early, in order to make sure that resolving
  # commands functions properly in other snippets!
  #
  xdg.configFile."bash/env.d/00_nono.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      if [ -n "$SANDBOXED_PATH" ]; then
        export PATH="$SANDBOXED_PATH"
        unset SANDBOXED_PATH
      fi
      if [ -n "$SANDBOXED_MANPATH" ]; then
        export MANPATH="$SANDBOXED_MANPATH"
        unset SANDBOXED_MANPATH
      fi
      if [ -n "$SANDBOXED_TERMINFO_DIRS" ]; then
        export TERMINFO_DIRS="$SANDBOXED_TERMINFO_DIRS"
        unset SANDBOXED_TERMINFO_DIRS
      fi
      if [ -n "$SANDBOXED_XDG_CONFIG_DIRS" ]; then
        export XDG_CONFIG_DIRS="$SANDBOXED_XDG_CONFIG_DIRS"
        unset SANDBOXED_XDG_CONFIG_DIRS
      fi
      if [ -n "$SANDBOXED_XDG_DATA_DIRS" ]; then
        export XDG_DATA_DIRS="$SANDBOXED_XDG_DATA_DIRS"
        unset SANDBOXED_XDG_DATA_DIRS
      fi
      if [ -n "$SANDBOXED_XDG_CACHE_HOME" ]; then
        export XDG_CACHE_HOME="$SANDBOXED_XDG_CACHE_HOME"
        unset SANDBOXED_XDG_CACHE_HOME
      fi
      if [ -n "$SANDBOXED_XDG_CONFIG_HOME" ]; then
        export XDG_CONFIG_HOME="$SANDBOXED_XDG_CONFIG_HOME"
        unset SANDBOXED_XDG_CONFIG_HOME
      fi
      if [ -n "$SANDBOXED_XDG_DATA_HOME" ]; then
        export XDG_DATA_HOME="$SANDBOXED_XDG_DATA_HOME"
        unset SANDBOXED_XDG_DATA_HOME
      fi
      if [ -n "$SANDBOXED_XDG_STATE_HOME" ]; then
        export XDG_STATE_HOME="$SANDBOXED_XDG_STATE_HOME"
        unset SANDBOXED_XDG_STATE_HOME
      fi
    '';
  };
  xdg.configFile."zsh/env.d/00_nono.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      if [[ -n "$SANDBOXED_PATH" ]]; then
        export PATH="$SANDBOXED_PATH"
        unset SANDBOXED_PATH
      fi
      if [[ -n "$SANDBOXED_MANPATH" ]]; then
        export MANPATH="$SANDBOXED_MANPATH"
        unset SANDBOXED_MANPATH
      fi
      if [[ -n "$SANDBOXED_TERMINFO_DIRS" ]]; then
        export TERMINFO_DIRS="$SANDBOXED_TERMINFO_DIRS"
        unset SANDBOXED_TERMINFO_DIRS
      fi
      if [[ -n "$SANDBOXED_XDG_CONFIG_DIRS" ]]; then
        export XDG_CONFIG_DIRS="$SANDBOXED_XDG_CONFIG_DIRS"
        unset SANDBOXED_XDG_CONFIG_DIRS
      fi
      if [[ -n "$SANDBOXED_XDG_DATA_DIRS" ]]; then
        export XDG_DATA_DIRS="$SANDBOXED_XDG_DATA_DIRS"
        unset SANDBOXED_XDG_DATA_DIRS
      fi
      if [[ -n "$SANDBOXED_XDG_CACHE_HOME" ]]; then
        export XDG_CACHE_HOME="$SANDBOXED_XDG_CACHE_HOME"
        unset SANDBOXED_XDG_CACHE_HOME
      fi
      if [[ -n "$SANDBOXED_XDG_CONFIG_HOME" ]]; then
        export XDG_CONFIG_HOME="$SANDBOXED_XDG_CONFIG_HOME"
        unset SANDBOXED_XDG_CONFIG_HOME
      fi
      if [[ -n "$SANDBOXED_XDG_DATA_HOME" ]]; then
        export XDG_DATA_HOME="$SANDBOXED_XDG_DATA_HOME"
        unset SANDBOXED_XDG_DATA_HOME
      fi
      if [[ -n "$SANDBOXED_XDG_STATE_HOME" ]]; then
        export XDG_STATE_HOME="$SANDBOXED_XDG_STATE_HOME"
        unset SANDBOXED_XDG_STATE_HOME
      fi
    '';
  };
  xdg.configFile."fish/env.d/00_nono.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      if test -n "$SANDBOXED_PATH"
        set -x PATH $(string split : $SANDBOXED_PATH)
        set -e SANDBOXED_PATH
      end
      if test -n "$SANDBOXED_MANPATH"
        set -x MANPATH $SANDBOXED_MANPATH
        set -e SANDBOXED_MANPATH
      end
      if test -n "$SANDBOXED_TERMINFO_DIRS"
        set -x TERMINFO_DIRS $SANDBOXED_TERMINFO_DIRS
        set -e SANDBOXED_TERMINFO_DIRS
      end
      if test -n "$SANDBOXED_XDG_CONFIG_DIRS"
        set -x XDG_CONFIG_DIRS $SANDBOXED_XDG_CONFIG_DIRS
        set -e SANDBOXED_XDG_CONFIG_DIRS
      end
      if test -n "$SANDBOXED_XDG_DATA_DIRS"
        set -x XDG_DATA_DIRS $SANDBOXED_XDG_DATA_DIRS
        set -e SANDBOXED_XDG_DATA_DIRS
      end
      if test -n "$SANDBOXED_XDG_CACHE_HOME"
        set -x XDG_CACHE_HOME $SANDBOXED_XDG_CACHE_HOME
        set -e SANDBOXED_XDG_CACHE_HOME
      end
      if test -n "$SANDBOXED_XDG_CONFIG_HOME"
        set -x XDG_CONFIG_HOME $SANDBOXED_XDG_CONFIG_HOME
        set -e SANDBOXED_XDG_CONFIG_HOME
      end
      if test -n "$SANDBOXED_XDG_DATA_HOME"
        set -x XDG_DATA_HOME $SANDBOXED_XDG_DATA_HOME
        set -e SANDBOXED_XDG_DATA_HOME
      end
      if test -n "$SANDBOXED_XDG_STATE_HOME"
        set -x XDG_STATE_HOME $SANDBOXED_XDG_STATE_HOME
        set -e SANDBOXED_XDG_STATE_HOME
      end
    '';
  };

  # Customized nono profile
  #
  xdg.configFile."nono/profiles/claude-code.toml".text = ''
    interactive = true

    [meta]
    name = "claude-code"
    version = "1.0.1"
    description = "Anthropic Claude Code CLI agent"
    "author" = "Nathan Acks (based on the default nono claude-code profile)"

    [filesystem]
    allow = [
      "${config.home.homeDirectory}/.claude",
      "${config.xdg.cacheHome}",
      "${config.xdg.configHome}/go",
      "${config.xdg.dataHome}/pnpm",
      "${config.xdg.stateHome}/pnpm",
      "/tmp",
      "/var/folders"
    ]
    read = [
      "${config.home.homeDirectory}/.ssh",
      "${config.home.homeDirectory}/Library/Application Support/Chromium",
      "${config.home.homeDirectory}/Library/Application Support/Google/Chrome",
      "${config.xdg.configHome}/chromium",
      "${config.xdg.configHome}/git",
      "${config.xdg.configHome}/google-chrome",
      "/etc/skel",
      "/nix"
    ]
    allow_file = [
      "${config.home.homeDirectory}/.claude.json",
      "${config.home.homeDirectory}/.claude.json.lock",
      "${config.home.homeDirectory}/.claude.lock",
      "/dev/null"
    ]
    read_file = [
      "${config.home.homeDirectory}/.bash_aliases",
      "${config.home.homeDirectory}/Library/Keychains/login.keychain-db",
      "/etc/bashrc"
    ]

    [network]
    block = false

    [workdir]
    access = "readwrite"

    [hooks.claude-code]
    event = "PostToolUseFailure"
    matcher = "Read|Write|Edit|Bash"
    script = "nono-hook.sh"
  '';
}
