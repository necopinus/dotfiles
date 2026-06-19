{
  config,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;

    # Work around weird issue in Termius where Zsh doesn't source its
    # environment properly
    #
    dotDir = "${config.home.homeDirectory}";

    # ~/.zshenv
    #
    envExtra = ''
      # Set OS type
      #
      OS="$(uname -s)"

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

      # Append ~/.local/bin to PATH, to allow for some work-around
      # symlinks
      #
      if [ -d "$HOME"/.local/bin ]; then
        export PATH="$PATH:$HOME/.local/bin"
      fi

      # Make sure that environment defined in /etc/environment.d is
      # available
      #
      if [[ -d /etc/environment.d ]]; then
        for FILE in $(find -L /etc/environment.d -type f -iname '*.conf' | sort); do
          source "$FILE"
        done
      fi

      # Source files for local environment setup
      #
      if [[ -d "$XDG_CONFIG_HOME"/zsh/env.d ]]; then
        for FILE in $(find -L "$XDG_CONFIG_HOME"/zsh/env.d -type f -iname '*.zsh' | sort); do
          source "$FILE"
        done
      fi

      # Set SHELL to the correct value
      #
      # We do this after the PATH has been fully configured to ensure
      # that we're catching the correct value
      #
      export SHELL="$(whence -p zsh)"
      if [[ -o login ]]; then
        if [[ -x "$(realpath /bin)"/zsh ]]; then
          export SHELL="$(realpath /bin)"/zsh
        elif [[ -x "$(realpath /usr/bin)"/zsh ]]; then
          export SHELL="$(realpath /usr/bin)"/zsh
        fi
      fi
    '';

    # ~/.zprofile
    #
    profileExtra = ''
      # Load system defaults if they exist
      #
      if [[ -f /etc/skel/.zprofile ]]; then
        source /etc/skel/.zprofile
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
        # Convenience aliases
        #
        alias :e=editor
        alias :q=exit

        # Source files for interactive shell setup
        #
        if [[ -d "$XDG_CONFIG_HOME"/zsh/rc.d ]]; then
          for FILE in $(find -L "$XDG_CONFIG_HOME"/zsh/rc.d -type f -iname '*.zsh' | sort); do
            source "$FILE"
          done
        fi
      '';
    in
      lib.mkMerge [
        initExtraFirst
        initExtra
      ];

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
