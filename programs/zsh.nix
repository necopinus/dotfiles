{
  pkgs,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;

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

      # Append Homebrew bin directory to PATH, since some GUI casks
      # install CLI binaries there
      #
      if [[ -d /opt/homebrew/bin ]]; then
        export PATH="$PATH:/opt/homebrew/bin"
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

        # Source various API keys into the environment
        #
        if [[ -f "$XDG_CONFIG_HOME/api-keys.env.sh" ]]; then
          source "$XDG_CONFIG_HOME/api-keys.env.sh"
        fi

        # Colorize man pages with bat
        #
        #   https://github.com/sharkdp/bat/issues/3053#issuecomment-2259573578
        #
        export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -l man'"

        # Convenience aliases
        #
        alias :e="$(whence -p "$EDITOR")"
        alias :q=exit
        alias cat="$(whence -p bat) -pp"
        alias diff="$(whence -p delta)"
        alias glow="$(whence -p glow) -s dark"
        alias htop="$(whence -p btm) --basic"
        alias imgcat="$(which chafa)"
        alias la="$(whence -p eza) --classify=auto --color=auto --group-directories-first --git --long --group --all"
        alias less="$(whence -p bat)"
        alias ll="$(whence -p eza) --classify=auto --color=auto --group-directories-first --git --long --group"
        alias ls="$(whence -p eza) --classify=auto --color=auto --group-directories-first --git"
        alias more="$(whence -p bat)"
        alias nvim="$(whence -p "$EDITOR")"
        alias rg="$(whence -p rg) --color=auto"
        alias sudo="/usr/bin/sudo -E"
        alias top="$(whence -p btm) --basic"
        alias vi="$(whence -p "$EDITOR")"
        alias vim="$(whence -p "$EDITOR")"

        # Wrap git and gpg to make sure that the current terminal is
        # correctly set for gpg-agent
        #
        function git {
          gpg-connect-agent UPDATESTARTUPTTY /bye > /dev/null
          GIT_EXEC="$(whence -p git)"
          $GIT_EXEC "$@"
        }
        function gpg {
          gpg-connect-agent UPDATESTARTUPTTY /bye > /dev/null
          GPG_EXEC="$(whence -p gpg)"
          $GPG_EXEC "$@"
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
