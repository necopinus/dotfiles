{
  config,
  pkgs,
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
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      strace # Used by the Anthropic Sandbox Runtime (part of Claude Code)
    ];

  #################### Claude Code ####################

  programs.claude-code = {
    enable = true;

    settings = {
      outputStyle = "Explanatory";
      alwaysThinkingEnabled = true;
      skipDangerousModePermissionPrompt = true;
      permissions = {
        deny = [
          "Bash(su *)"
          "Bash(sudo *)"
          "Edit(/${config.home.homeDirectory}/.cert)"
          "Edit(/${config.home.homeDirectory}/.gitconfig)"
          "Edit(/${config.home.homeDirectory}/.gnupg)"
          "Edit(/${config.home.homeDirectory}/.kde/share/apps/networkmanagement)"
          "Edit(/${config.home.homeDirectory}/.ssh)"
          "Edit(/${config.home.homeDirectory}/Desktop)"
          "Edit(/${config.home.homeDirectory}/Documents)"
          "Edit(/${config.home.homeDirectory}/Downloads)"
          "Edit(/${config.home.homeDirectory}/Library)"
          "Edit(/${config.home.homeDirectory}/Movies)"
          "Edit(/${config.home.homeDirectory}/Music)"
          "Edit(/${config.home.homeDirectory}/Pictures)"
          "Edit(/${config.home.homeDirectory}/Public)"
          "Edit(/${config.home.homeDirectory}/Templates)"
          "Edit(/${config.home.homeDirectory}/Videos)"
          "Edit(/${config.xdg.configHome}/git)"
          "Edit(/${config.xdg.dataHome}/certs)"
          "Edit(/${config.xdg.dataHome}/keyrings)"
          "Edit(/${config.xdg.dataHome}/kwalletd)"
          "Edit(/${config.xdg.dataHome}/networkmanagement)"
          "Edit(//etc/NetworkManager)"
          "Edit(//etc/ssh)"
          "Edit(//mnt)"
          "Edit(//Volumes)"
          "Read(/${config.home.homeDirectory}/.cert)"
          "Read(/${config.home.homeDirectory}/.gnupg)"
          "Read(/${config.home.homeDirectory}/.kde/share/apps/networkmanagement)"
          "Read(/${config.home.homeDirectory}/Desktop)"
          "Read(/${config.home.homeDirectory}/Documents)"
          "Read(/${config.home.homeDirectory}/Downloads)"
          "Read(/${config.home.homeDirectory}/Movies)"
          "Read(/${config.home.homeDirectory}/Music)"
          "Read(/${config.home.homeDirectory}/Pictures)"
          "Read(/${config.home.homeDirectory}/Public)"
          "Read(/${config.home.homeDirectory}/Templates)"
          "Read(/${config.home.homeDirectory}/Videos)"
          "Read(/${config.xdg.dataHome}/certs)"
          "Read(/${config.xdg.dataHome}/keyrings)"
          "Read(/${config.xdg.dataHome}/kwalletd)"
          "Read(/${config.xdg.dataHome}/networkmanagement)"
          "Read(//etc/NetworkManager)"
          "Read(//etc/ssh)"
          "Read(//mnt)"
          "Read(//Volumes)"
        ];
        ask = [
          "Bash(rm *)"
        ];
        allow = [
          "Bash(ls *)"
          "Read(/${config.home.homeDirectory}/Library/Application Support/Chromium/Default/Extensions)"
          "Read(/${config.home.homeDirectory}/Library/Application Support/Chromium/NativeMessagingHosts)"
          "Read(/${config.home.homeDirectory}/Library/Application Support/Google/Chrome/Default/Extensions)"
          "Read(/${config.home.homeDirectory}/Library/Application Support/Google/Chrome/NativeMessagingHosts)"
          "Read(/${config.xdg.configHome}/chromium/Default/Extensions)"
          "Read(/${config.xdg.configHome}/chromium/NativeMessagingHosts)"
          "Read(/${config.xdg.configHome}/google-chrome/Default/Extensions)"
          "Read(/${config.xdg.configHome}/google-chrome/NativeMessagingHosts)"
        ];
      };
      sandbox = {
        enabled = true;
        autoAllowBashIfSandboxed = true;
        allowUnsandboxedCommands = false;
        network = {
          allowedDomains = [];
          allowUnixSockets = [];
          allowLocalBinding = true;
        };
        excludedCommands = [];
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
        CLAUDE_CODE_EXEC="$(${pkgs.uutils-coreutils-noprefix}/bin/realpath "$(which claude)")"

        if [[ "$CLAUDE_CODE_EXEC" == */scripts/claude ]] || [[ -n "$CLAUDECODE" ]] || [[ -n "$NONO_CAP_FILE" ]]; then
          "$CLAUDE_CODE_EXEC" "$@"
        else
          # Note that all of the allow/allow-file/read/read-file lines
          # (except for `--allow .`) can be removed when nono v0.6.0
          # hits nixpkgs-unstable
          #
          nono run \
            --profile claude-code \
            --allow . \
            $([[ -d "$XDG_CACHE_HOME"/go-build ]] && echo -n "--allow $XDG_CACHE_HOME/go-build") \
            $([[ -d "$XDG_CACHE_HOME"/pip ]] && echo -n "--allow $XDG_CACHE_HOME/pip") \
            $([[ -d "$XDG_CACHE_HOME"/pnpm ]] && echo -n "--allow $XDG_CACHE_HOME/pnpm") \
            $([[ -d "$XDG_CACHE_HOME"/uv ]] && echo -n "--allow $XDG_CACHE_HOME/uv") \
            $([[ -d "$XDG_CONFIG_HOME"/go ]] && echo -n "--allow $XDG_CONFIG_HOME/go") \
            $([[ -d "$XDG_DATA_HOME"/pnpm ]] && echo -n "--allow $XDG_DATA_HOME/pnpm") \
            $([[ -d "$XDG_STATE_HOME"/pnpm ]] && echo -n "--allow $XDG_STATE_HOME/pnpm") \
            $([[ -d /tmp ]] && echo -n "--allow /tmp") \
            $([[ -d /var/folders ]] && echo -n "--allow /var/folders") \
            $([[ -e /dev/null ]] && echo -n "--allow-file /dev/null") \
            $([[ -d "$HOME"/.ssh ]] && echo -n "--read $HOME/.ssh") \
            $([[ -d "$HOME"/Library/"Application Support"/Chromium ]] && echo -n "--read $HOME/Library/Application\\ Support/Chromium") \
            $([[ -d "$HOME"/Library/"Application Support"/Google/Chrome ]] && echo -n "--read $HOME/Library/Application\\ Support/Google/Chrome") \
            $([[ -d "$XDG_CONFIG_HOME"/chromium ]] && echo -n "--read $XDG_CONFIG_HOME/chromium") \
            $([[ -d "$XDG_CONFIG_HOME"/google-chrome ]] && echo -n "--read $XDG_CONFIG_HOME/google-chrome") \
            $([[ -d /etc/skel ]] && echo -n "--read /etc/skel") \
            $([[ -d /nix ]] && echo -n "--read /nix") \
            $([[ -e "$HOME"/.bash_aliases ]] && echo -n "--read-file $HOME/.bash_aliases") \
            $([[ -e /etc/bashrc ]] && echo -n "--read-file /etc/bashrc") \
            -- "$CLAUDE_CODE_EXEC" --dangerously-skip-permissions "$@"
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
          # Note that all of the allow/allow-file/read/read-file
          # lines (except for `--allow .`) can be removed when nono
          # v0.6.0 hits nixpkgs-unstable
          #
          nono run \
            --profile claude-code \
            --allow . \
            $([[ -d "$XDG_CACHE_HOME"/go-build ]] && echo -n "--allow $XDG_CACHE_HOME/go-build") \
            $([[ -d "$XDG_CACHE_HOME"/pip ]] && echo -n "--allow $XDG_CACHE_HOME/pip") \
            $([[ -d "$XDG_CACHE_HOME"/pnpm ]] && echo -n "--allow $XDG_CACHE_HOME/pnpm") \
            $([[ -d "$XDG_CACHE_HOME"/uv ]] && echo -n "--allow $XDG_CACHE_HOME/uv") \
            $([[ -d "$XDG_CONFIG_HOME"/go ]] && echo -n "--allow $XDG_CONFIG_HOME/go") \
            $([[ -d "$XDG_DATA_HOME"/pnpm ]] && echo -n "--allow $XDG_DATA_HOME/pnpm") \
            $([[ -d "$XDG_STATE_HOME"/pnpm ]] && echo -n "--allow $XDG_STATE_HOME/pnpm") \
            $([[ -d /tmp ]] && echo -n "--allow /tmp") \
            $([[ -d /var/folders ]] && echo -n "--allow /var/folders") \
            $([[ -e /dev/null ]] && echo -n "--allow-file /dev/null") \
            $([[ -d "$HOME"/.ssh ]] && echo -n "--read $HOME/.ssh") \
            $([[ -d "$HOME"/Library/"Application Support"/Chromium ]] && echo -n "--read $HOME/Library/Application\\ Support/Chromium") \
            $([[ -d "$HOME"/Library/"Application Support"/Google/Chrome ]] && echo -n "--read $HOME/Library/Application\\ Support/Google/Chrome") \
            $([[ -d "$XDG_CONFIG_HOME"/chromium ]] && echo -n "--read $XDG_CONFIG_HOME/chromium") \
            $([[ -d "$XDG_CONFIG_HOME"/google-chrome ]] && echo -n "--read $XDG_CONFIG_HOME/google-chrome") \
            $([[ -d /etc/skel ]] && echo -n "--read /etc/skel") \
            $([[ -d /nix ]] && echo -n "--read /nix") \
            $([[ -e "$HOME"/.bash_aliases ]] && echo -n "--read-file $HOME/.bash_aliases") \
            $([[ -e /etc/bashrc ]] && echo -n "--read-file /etc/bashrc") \
            -- "$CLAUDE_CODE_EXEC" --dangerously-skip-permissions "$@"
        fi
      }
    '';
  };
  programs.fish.functions."claude" = ''
    set CLAUDE_CODE_EXEC $(${pkgs.uutils-coreutils-noprefix}/bin/realpath $(${pkgs.which}/bin/which claude))

    if string match "*/scripts/claude" $CLAUDE_CODE_EXEC &> /dev/null; or test -n "$CLAUDECODE"; or test -n "$NONO_CAP_FILE"
      $CLAUDE_CODE_EXEC $argv
    else
      # Note that all of the allow/allow-file/read/read-file lines
      # (except for `--allow .`) can be removed when nono v0.6.0
      # hits nixpkgs-unstable
      #
      nono run \
        --profile claude-code \
        --allow . \
        (test -d $XDG_CACHE_HOME/go-build && echo -n "--allow $XDG_CACHE_HOME/go-build") \
        (test -d $XDG_CACHE_HOME/pip && echo -n "--allow $XDG_CACHE_HOME/pip") \
        (test -d $XDG_CACHE_HOME/pnpm && echo -n "--allow $XDG_CACHE_HOME/pnpm") \
        (test -d $XDG_CACHE_HOME/uv && echo -n "--allow $XDG_CACHE_HOME/uv") \
        (test -d $XDG_CONFIG_HOME/go && echo -n "--allow $XDG_CONFIG_HOME/go") \
        (test -d $XDG_DATA_HOME/pnpm && echo -n "--allow $XDG_DATA_HOME/pnpm") \
        (test -d $XDG_STATE_HOME/pnpm && echo -n "--allow $XDG_STATE_HOME/pnpm") \
        (test -d /tmp && echo -n "--allow /tmp") \
        (test -d /var/folders && echo -n "--allow /var/folders") \
        (test -e /dev/null && echo -n "--allow-file /dev/null") \
        (test -d $HOME/.ssh && echo -n "--read $HOME/.ssh") \
        (test -d $HOME/Library/"Application Support"/Chromium && echo -n "--read $HOME/Library/Application\\ Support/Chromium") \
        (test -d $HOME/Library/"Application Support"/Google/Chrome && echo -n "--read $HOME/Library/Application\\ Support/Google/Chrome") \
        (test -d $XDG_CONFIG_HOME/chromium && echo -n "--read $XDG_CONFIG_HOME/chromium") \
        (test -d $XDG_CONFIG_HOME/google-chrome && echo -n "--read $XDG_CONFIG_HOME/google-chrome") \
        (test -d /etc/skel && echo -n "--read /etc/skel") \
        (test -d /nix && echo -n "--read /nix") \
        (test -e $HOME/.bash_aliases && echo -n "--read-file $HOME/.bash_aliases") \
        (test -e /etc/bashrc && echo -n "--read-file /etc/bashrc") \
        -- $CLAUDE_CODE_EXEC --dangerously-skip-permissions $argv
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

        export SANDBOXED_PATH SANDBOXED_MANPATH SANDBOXED_TERMINFO_DIRS SANDBOXED_XDG_CONFIG_DIRS SANDBOXED_XDG_DATA_DIRS

        eval ${pkgs.uutils-coreutils-noprefix}/bin/env -S \
          $([[ -z "$SANDBOXED_PATH" ]] && echo -n "-u PATH") \
          $([[ -z "$SANDBOXED_MANPATH" ]] && echo -n "-u MANPATH") \
          $([[ -z "$SANDBOXED_TERMINFO_DIRS" ]] && echo -n "-u TERMINFO_DIRS") \
          $([[ -z "$SANDBOXED_XDG_CONFIG_DIRS" ]] && echo -n "-u XDG_CONFIG_DIRS") \
          $([[ -z "$SANDBOXED_XDG_DATA_DIRS" ]] && echo -n "-u XDG_DATA_DIRS") \
          $([[ -n "$SANDBOXED_PATH" ]] && echo -n "PATH=\"$SANDBOXED_PATH\"") \
          $([[ -n "$SANDBOXED_MANPATH" ]] && echo -n "MANPATH=\"$SANDBOXED_MANPATH\"") \
          $([[ -n "$SANDBOXED_TERMINFO_DIRS" ]] && echo -n "XDG_CONFIG_DIRS=\"$SANDBOXED_TERMINFO_DIRS\"") \
          $([[ -n "$SANDBOXED_XDG_CONFIG_DIRS" ]] && echo -n "XDG_CONFIG_DIRS=\"$SANDBOXED_XDG_CONFIG_DIRS\"") \
          $([[ -n "$SANDBOXED_XDG_DATA_DIRS" ]] && echo -n "XDG_DATA_DIRS=\"$SANDBOXED_XDG_DATA_DIRS\"") \
          "$(${pkgs.uutils-coreutils-noprefix}/bin/realpath "$(${pkgs.which}/bin/which nono)")" "$@"

        unset SANDBOXED_PATH SANDBOXED_MANPATH SANDBOXED_TERMINFO_DIRS SANDBOXED_XDG_CONFIG_DIRS SANDBOXED_XDG_DATA_DIRS
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

        export SANDBOXED_PATH SANDBOXED_MANPATH SANDBOXED_TERMINFO_DIRS SANDBOXED_XDG_CONFIG_DIRS SANDBOXED_XDG_DATA_DIRS

        eval ${pkgs.uutils-coreutils-noprefix}/bin/env -S \
          $([[ -z "$SANDBOXED_PATH" ]] && echo -n "-u PATH") \
          $([[ -z "$SANDBOXED_MANPATH" ]] && echo -n "-u MANPATH") \
          $([[ -z "$SANDBOXED_TERMINFO_DIRS" ]] && echo -n "-u TERMINFO_DIRS") \
          $([[ -z "$SANDBOXED_XDG_CONFIG_DIRS" ]] && echo -n "-u XDG_CONFIG_DIRS") \
          $([[ -z "$SANDBOXED_XDG_DATA_DIRS" ]] && echo -n "-u XDG_DATA_DIRS") \
          $([[ -n "$SANDBOXED_PATH" ]] && echo -n "PATH=\"$SANDBOXED_PATH\"") \
          $([[ -n "$SANDBOXED_MANPATH" ]] && echo -n "MANPATH=\"$SANDBOXED_MANPATH\"") \
          $([[ -n "$SANDBOXED_TERMINFO_DIRS" ]] && echo -n "TERMINFO_DIRS=\"$SANDBOXED_TERMINFO_DIRS\"") \
          $([[ -n "$SANDBOXED_XDG_CONFIG_DIRS" ]] && echo -n "XDG_CONFIG_DIRS=\"$SANDBOXED_XDG_CONFIG_DIRS\"") \
          $([[ -n "$SANDBOXED_XDG_DATA_DIRS" ]] && echo -n "XDG_DATA_DIRS=\"$SANDBOXED_XDG_DATA_DIRS\"") \
          "$(${pkgs.uutils-coreutils-noprefix}/bin/realpath "$(whence -p nono)")" "$@"

        unset SANDBOXED_PATH SANDBOXED_MANPATH SANDBOXED_TERMINFO_DIRS SANDBOXED_XDG_CONFIG_DIRS SANDBOXED_XDG_DATA_DIRS
      }
    '';
  };
  programs.fish.functions."nono" = ''
    set NONO_EXEC $(${pkgs.uutils-coreutils-noprefix}/bin/realpath $(${pkgs.which}/bin/which nono))

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

    eval ${pkgs.uutils-coreutils-noprefix}/bin/env -S \
      (test -z "$SANDBOXED_PATH" && echo -n "-u PATH") \
      (test -z "$SANDBOXED_MANPATH" && echo -n "-u MANPATH") \
      (test -z "$SANDBOXED_TERMINFO_DIRS" && echo -n "-u TERMINFO_DIRS") \
      (test -z "$SANDBOXED_XDG_CONFIG_DIRS" && echo -n "-u XDG_CONFIG_DIRS") \
      (test -z "$SANDBOXED_XDG_DATA_DIRS" && echo -n "-u XDG_DATA_DIRS") \
      (test -n "$SANDBOXED_PATH" && echo -n "PATH=\"$SANDBOXED_PATH\"") \
      (test -n "$SANDBOXED_MANPATH" && echo -n "MANPATH=\"$SANDBOXED_MANPATH\"") \
      (test -n "$SANDBOXED_TERMINFO_DIRS" && echo -n "TERMINFO_DIRS=\"$SANDBOXED_TERMINFO_DIRS\"") \
      (test -n "$SANDBOXED_XDG_CONFIG_DIRS" && echo -n "XDG_CONFIG_DIRS=\"$SANDBOXED_XDG_CONFIG_DIRS\"") \
      (test -n "$SANDBOXED_XDG_DATA_DIRS" && echo -n "XDG_DATA_DIRS=\"$SANDBOXED_XDG_DATA_DIRS\"") \
      $NONO_EXEC $argv

    set -e SANDBOXED_PATH
    set -e SANDBOXED_MANPATH
    set -e SANDBOXED_TERMINFO_DIRS
    set -e SANDBOXED_XDG_CONFIG_DIRS
    set -e SANDBOXED_XDG_DATA_DIRS
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
    '';
  };

  # Customized nono profile
  #
  xdg.configFile."nono/profiles/claude-code.json".text = ''
    {
      "meta": {
        "name": "claude-code",
        "version": "1.0.1",
        "description": "Anthropic Claude Code CLI agent",
        "author": "Nathan Acks (based on default nono profile)"
      },
      "security": {
        "groups": [
          "go_runtime",
          "node_runtime",
          "python_runtime",
          "rust_runtime",
          "unlink_protection",
          "user_caches_macos"
        ]
      },
      "trust_groups": [],
      "filesystem": {
        "allow": [
          "${config.home.homeDirectory}/.claude"
          "${config.xdg.cacheHome}/go-build",
          "${config.xdg.cacheHome}/pip",
          "${config.xdg.cacheHome}/pnpm",
          "${config.xdg.cacheHome}/uv",
          "${config.xdg.configHome}/go",
          "${config.xdg.configHome}/zsh",
          "${config.xdg.dataHome}/pnpm",
          "${config.xdg.stateHome}/pnpm",
          "/tmp",
          "/var/folders"
        ],
        "read": [
          "${config.home.homeDirectory}/.ssh",
          "${config.home.homeDirectory}/Library/Application Support/Chromium",
          "${config.home.homeDirectory}/Library/Application Support/Google/Chrome",
          "${config.xdg.configHome}/chromium",
          "${config.xdg.configHome}/google-chrome",
          "/etc/skel",
          "/nix"
        ],
        "allow_file": [
          "${config.home.homeDirectory}/.claude.json",
          "/dev/null"
        ],
        "read_file": [
          "${config.home.homeDirectory}/.bash_aliases",
          "${config.home.homeDirectory}/Library/Keychains/login.keychain-db",
          "/etc/bashrc"
        ]
      },
      "network": {
        "block": false
      },
      "workdir": {
        "access": "readwrite"
      },
      "hooks": {
        "claude-code": {
          "event": "PostToolUseFailure",
          "matcher": "Read|Write|Edit|Bash",
          "script": "nono-hook.sh"
        }
      },
      "undo": {
        "exclude_patterns": [
          "node_modules",
          ".next",
          "__pycache__",
          "target"
        ],
        "exclude_globs": [
          "*.tmp.[0-9]*.[0-9]*"
        ]
      },
      "interactive": true
    }
  '';
}
