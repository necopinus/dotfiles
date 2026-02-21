{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;

    # Move Zsh configuration files; can be removed when
    # home.stateVersion is advanced to 26.05
    #
    dotDir = "${config.xdg.configHome}/zsh";

    # ~/.zshenv
    #
    sessionVariables = {
      BAT_THEME = "ansi";
      DELTA_FEATURES = "+generic-dark-theme";
    };

    envExtra = ''
      # Load system defaults if they exist
      #
      if [[ -f /etc/skel/.zshenv ]]; then
        source /etc/skel/.zshenv
      fi

      # Make sure that Nix is set up
      #
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]] && [[ -z "$__ETC_PROFILE_NIX_SOURCED" ]]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi
      if [[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]] && [[ -z "$__HM_SESS_VARS_SOURCED" ]]; then
        source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi

      # Append Homebrew bin directory to PATH, since some GUI casks
      # install CLI binaries there
      #
      if [[ -d /opt/homebrew/bin ]]; then
        export PATH="$PATH:/opt/homebrew/bin"
      fi

      # Set SHELL to the correct value
      #
      if [[ -o login ]]; then
        if [[ -x "$(realpath /bin)"/zsh ]]; then
          export SHELL="$(realpath /bin)"/zsh
        elif [[ -x "$(realpath /usr/bin)"/zsh ]]; then
          export SHELL="$(realpath /usr/bin)"/zsh
        else
          export SHELL="$(which zsh)"
        fi
      else
        export SHELL="$(which zsh)"
      fi
    '';

    # ~/.zprofile
    #
    profileExtra = ''
      # Set OS type
      #
      OS="$(uname -s)"

      # Load system defaults if they exist
      #
      if [[ -f /etc/skel/.zprofile ]]; then
        source /etc/skel/.zprofile
      fi

      # Load $XDG_CONFIG_HOME/user-dirs.dirs when applicable
      #
      if [[ "$OS" == "Darwin" ]] && [[ -f "$XDG_CONFIG_HOME/user-dirs.dirs" ]]; then
        eval "$(cat "$XDG_CONFIG_HOME/user-dirs.dirs" | sed "s/^XDG_/export XDG_/")"
      fi
    '';

    # ~/.zshrc
    #
    enableCompletion = true;

    history = {
      append = true;
      expireDuplicatesFirst = true;
      extended = true;
      findNoDups = true;
      ignoreAllDups = true;
      ignoreDups = true;
      saveNoDups = true;
      share = true;
    };

    setOptions = [
      "COMBINING_CHARS"
      "HIST_REDUCE_BLANKS"
      "HIST_VERIFY"
      "INC_APPEND_HISTORY"
      "NO_clobber"
      "interactivecomments"
      "nonomatch"
    ];

    initContent = let
      # Loads early, even before enableCompletion
      #
      initExtraFirst = lib.mkOrder 500 ''
        # Load system defaults if they exist
        #
        if [[ -f /etc/skel/.zshrc ]]; then
          source /etc/skel/.zshrc
        fi
      '';

      # Loads in the normal position (near the end)
      #
      initExtra = lib.mkOrder 1000 ''
        # Set OS type
        #
        OS="$(uname -s)"

        # Start ssh-agent, if necessary
        #
        #   https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login/18915067#18915067
        #
        if [[ -z "$SSH_AUTH_SOCK" ]]; then
          if [[ -f "$HOME"/.ssh/agent.env ]]; then
            source "$HOME"/.ssh/agent.env
          fi
          if [[ -z "$SSH_AGENT_PID" ]] || [[ $(ps -ef | grep -v grep | grep -c "$SSH_AGENT_PID") -eq 0 ]]; then
            if [[ ! -d "$HOME"/.ssh ]]; then
              mkdir -p "$HOME"/.ssh
            fi
            ssh-agent | sed '/^echo/d' > "$HOME"/.ssh/agent.env
            source "$HOME"/.ssh/agent.env
          fi
        fi

        # Colorize man pages with batman
        #
        eval "$(batman --export-env)"

        # Convenience aliases
        #
        alias :e="$(whence -p "$EDITOR")"
        alias :q=exit
        alias cat="$(whence -p bat) -pp"
        alias diff="$(whence -p delta)"
        alias glow="$(whence -p glow) -s dark"
        alias htop="$(whence -p btm) --basic"
        alias imgcat="$(whence -p chafa)"
        alias jq="$(whence -p jaq)"
        alias la="$(whence -p eza) --classify=auto --color=auto --group-directories-first --git --group --long --all"
        alias less="$(whence -p bat)"
        alias ll="$(whence -p eza) --classify=auto --color=auto --group-directories-first --git --group --long"
        alias ls="$(whence -p eza) --classify=auto --color=auto --group-directories-first --git --group"
        alias more="$(whence -p bat)"
        alias nvim="$(whence -p "$EDITOR")"
        alias prettycat="$(whence -p prettybat)"
        alias rg="$(whence -p batgrep)"
        alias sudo="/usr/bin/sudo -E"
        alias top="$(whence -p btm) --basic"
        alias vi="$(whence -p "$EDITOR")"
        alias vim="$(whence -p "$EDITOR")"
        alias watch="$(which batwatch)"
        alias yq="$(whence -p jaq)"

        # Fix zeditor on macOS
        #
        if [[ "$OS" == "Darwin" ]]; then
          if [[ -n "$(whence -p zed)" ]]; then
            if [[ -d /Applications/Zed.app ]]; then
              alias zed="$(whence -p zed) --zed /Applications/Zed.app"
              alias zeditor="$(whence -p zed) --zed /Applications/Zed.app"
            elif [[ -d "$HOME/Applications/Home Manager Apps/Zed.app" ]]; then
              alias zed="$(whence -p zed) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
              alias zeditor="$(whence -p zed) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
            fi
          elif [[ -n "$(whence -p zeditor)" ]]; then
            if [[ -d /Applications/Zed.app ]]; then
              alias zed="$(whence -p zeditor) --zed /Applications/Zed.app"
              alias zeditor="$(whence -p zeditor) --zed /Applications/Zed.app"
            elif [[ -d "$HOME/Applications/Home Manager Apps/Zed.app" ]]; then
              alias zed="$(whence -p zeditor) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
              alias zeditor="$(whence -p zeditor) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
            fi
          fi
        fi

        # Wrap man/batman to supress readlink errors
        #
        function man {
          MAN_EXEC="$(whence -p man)"
          $MAN_EXEC "$@" 2> /dev/null
        }
        function batman {
          BATMAN_EXEC="$(whence -p batman)"
          $BATMAN_EXEC "$@" 2> /dev/null
        }

        # Wrap Claude Code in the Nono sandbox, but only if not called
        # recursively (to avoid sandboxing the sandbox)
        #
        # Note that we have to resolve (potentially) critical paths in
        # the environment, as nono will not follow home-manager's
        # symlinks without making all of $HOME readable
        #
        function nono {
          SEP=""
          NEW_PATH=""
          while IFS=: read -d: -r DIR; do
            if [[ -d "$DIR" ]]; then
              NEW_PATH="$NEW_PATH$SEP$(realpath "$DIR")"
              if [[ -z "$SEP" ]]; then
                SEP=":"
              fi
            fi
          done <<<"''${PATH:+"''${PATH}:"}"

          SEP=""
          NEW_MANPATH=""
          while IFS=: read -d: -r DIR; do
            if [[ -d "$DIR" ]]; then
              NEW_MANPATH="$NEW_MANPATH$SEP$(realpath "$DIR")"
              if [[ -z "$SEP" ]]; then
                SEP=":"
              fi
            fi
          done <<<"''${MANPATH:+"''${MANPATH}:"}"

          SEP=""
          NEW_XDG_CONFIG_DIRS=""
          while IFS=: read -d: -r DIR; do
            if [[ -d "$DIR" ]]; then
              NEW_XDG_CONFIG_DIRS="$NEW_XDG_CONFIG_DIRS$SEP$(realpath "$DIR")"
              if [[ -z "$SEP" ]]; then
                SEP=":"
              fi
            fi
          done <<<"''${XDG_CONFIG_DIRS:+"''${XDG_CONFIG_DIRS}:"}"

          SEP=""
          NEW_XDG_DATA_DIRS=""
          while IFS=: read -d: -r DIR; do
            if [[ -d "$DIR" ]]; then
              NEW_XDG_DATA_DIRS="$NEW_XDG_DATA_DIRS$SEP$(realpath "$DIR")"
              if [[ -z "$SEP" ]]; then
                SEP=":"
              fi
            fi
          done <<<"''${XDG_DATA_DIRS:+"''${XDG_DATA_DIRS}:"}"

          env -S \
            $([[ -z "$NEW_PATH" ]] && echo -n "-u PATH") \
            $([[ -z "$NEW_MANPATH" ]] && echo -n "-u MANPATH") \
            $([[ -z "$NEW_XDG_CONFIG_DIRS" ]] && echo -n "-u XDG_CONFIG_DIRS") \
            $([[ -z "$NEW_XDG_DATA_DIRS" ]] && echo -n "-u XDG_DATA_DIRS") \
            $([[ -n "$NEW_PATH" ]] && echo -n "PATH=\"$NEW_PATH\"") \
            $([[ -n "$NEW_MANPATH" ]] && echo -n "MANPATH=\"$NEW_MANPATH\"") \
            $([[ -n "$NEW_XDG_CONFIG_DIRS" ]] && echo -n "XDG_CONFIG_DIRS=\"$NEW_XDG_CONFIG_DIRS\"") \
            $([[ -n "$NEW_XDG_DATA_DIRS" ]] && echo -n "XDG_DATA_DIRS=\"$NEW_XDG_DATA_DIRS\"") \
            CLAUDE_CODE_SHELL="$(realpath $(whence -p bash))" \
            "$(realpath "$(whence -p nono)")" "$@"
        }
        function claude {
          CLAUDE_CODE_EXEC="$(realpath "$(whence -p claude)")"

          if [[ "$CLAUDE_CODE_EXEC" == */scripts/claude ]] || [[ -n "$CLAUDECODE" ]]; then
            "$CLAUDE_CODE_EXEC" "$@"
          else
            # Note that all of the allow/allow-file/read/read-fil lines
            # (except for `--allow .`) can be removed when nono v0.5.0
            # hits nixpkgs-unstable
            #
            nono run \
              --profile claude-code \
              --allow . \
              $([[ -d "$XDG_CACHE_HOME"/fish ]] && echo -n "--allow $XDG_CACHE_HOME/fish") \
              $([[ -d "$XDG_CACHE_HOME"/go-build ]] && echo -n "--allow $XDG_CACHE_HOME/go-build") \
              $([[ -d "$XDG_CACHE_HOME"/pip ]] && echo -n "--allow $XDG_CACHE_HOME/pip") \
              $([[ -d "$XDG_CACHE_HOME"/pnpm ]] && echo -n "--allow $XDG_CACHE_HOME/pnpm") \
              $([[ -d "$XDG_CACHE_HOME"/starship ]] && echo -n "--allow $XDG_CACHE_HOME/starship") \
              $([[ -d "$XDG_CACHE_HOME"/uv ]] && echo -n "--allow $XDG_CACHE_HOME/uv") \
              $([[ -d "$XDG_CONFIG_HOME"/fish ]] && echo -n "--allow $XDG_CONFIG_HOME/fish") \
              $([[ -d "$XDG_CONFIG_HOME"/go ]] && echo -n "--allow $XDG_CONFIG_HOME/go") \
              $([[ -d "$XDG_DATA_HOME"/delta ]] && echo -n "--allow $XDG_DATA_HOME/delta") \
              $([[ -d "$XDG_DATA_HOME"/fish ]] && echo -n "--allow $XDG_DATA_HOME/fish") \
              $([[ -d "$XDG_DATA_HOME"/pnpm ]] && echo -n "--allow $XDG_DATA_HOME/pnpm") \
              $([[ -d "$XDG_STATE_HOME"/pnpm ]] && echo -n "--allow $XDG_STATE_HOME/pnpm") \
              $([[ -d /tmp ]] && echo -n "--allow /tmp") \
              $([[ -d /var/folders ]] && echo -n "--allow /var/folders") \
              $([[ -e /dev/null ]] && echo -n "--allow-file /dev/null") \
              $([[ -d "$HOME"/.ssh ]] && echo -n "--read $HOME/.ssh") \
              $([[ -d "$XDG_CACHE_HOME"/bat ]] && echo -n "--read $XDG_CACHE_HOME/bat") \
              $([[ -d "$XDG_CONFIG_HOME" ]] && echo -n "--read $XDG_CONFIG_HOME") \
              $([[ -d /etc/skel ]] && echo -n "--read /etc/skel") \
              $([[ -d /nix ]] && echo -n "--read /nix") \
              $([[ -d /usr/share ]] && echo -n "--read /usr/share") \
              $([[ -e "$HOME"/.bash_aliases ]] && echo -n "--read-file $HOME/.bash_aliases") \
              $([[ -e /etc/bashrc ]] && echo -n "--read-file /etc/bashrc") \
              -- "$CLAUDE_CODE_EXEC" --dangerously-skip-permissions "$@"
          fi
        }

        # Convenience function for launching graphical apps from the terminal
        #
        if [[ "$OS" == "Linux" ]]; then
            function xcv {
                nohup "$@" 2>/dev/null
            }
        fi
      '';
    in
      lib.mkMerge [
        initExtraFirst
        initExtra
      ];

    enableVteIntegration = pkgs.stdenv.isLinux;

    # ~/.zlogin
    #
    loginExtra = ''
      # Load system defaults if they exist
      #
      if [[ -f /etc/skel/.zlogin ]]; then
        source /etc/skel/.zlogin
      fi
    '';
  };
}
