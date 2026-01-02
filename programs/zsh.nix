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

        # Source various API keys into the environment
        #
        if [[ -f "$XDG_CONFIG_HOME/api-keys.env.sh" ]]; then
          source "$XDG_CONFIG_HOME/api-keys.env.sh"
        fi

        # Colorize man pages with batman, and then some
        #
        eval "$(batman --export-env)"
        eval "$(batpipe)"

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
          alias zeditor="$(whence -p zeditor) --zed \"$HOME/Applications/Home Manager Apps/Zed.app\""
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
