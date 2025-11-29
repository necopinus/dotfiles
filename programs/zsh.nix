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
        # Source various API keys into the environment
        #
        if [[ -f "$XDG_CONFIG_HOME/api-keys.env.sh" ]]; then
          source "$XDG_CONFIG_HOME/api-keys.env.sh"
        fi

        # Set LS_COLORS, as a surprising number of applications look wonky is
        # this variable isn't available
        #
        if [[ -n "$(which dircolors 2>/dev/null)" ]]; then
          eval "$(dircolors)"
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
        alias ccat="$(whence -p cat)"
        alias ddiff="$(whence -p diff)"
        alias diff="$(whence -p delta)"
        alias glow="$(whence -p glow) -s dark"
        alias htop="$(whence -p btm)"
        alias la="$(whence -p eza) --classify=auto --color=auto --long --all"
        alias less="$(whence -p bat)"
        alias ll="$(whence -p eza) --classify=auto --color=auto --long"
        alias lless="$(whence -p less)"
        alias lls="$(whence -p ls)"
        alias ls="$(whence -p eza) --classify=auto --color=auto"
        alias mmore="$(whence -p more)"
        alias more="$(whence -p bat)"
        alias nvim="$(whence -p "$EDITOR")"
        alias rg="$(whence -p rg) --color=auto"
        alias top="$(whence -p btm)"
        alias ttop="$(whence -p top)"
        alias vi="$(whence -p "$EDITOR")"
        alias vim="$(whence -p "$EDITOR")"

        if [[ -n "$(whence -p sudo 2>/dev/null)" ]]; then
            alias sudo="$(whence -p sudo) -E"

            if [[ "$(uname -s)" == "Linux" ]] && [[ -x /sbin/shutdown ]]; then
                alias shutdown="$(whence -p sudo) /sbin/shutdown -h now"
            fi
        fi

        # Convenience function for launching graphical apps from the terminal
        #
        if [[ "$(uname -s)" == "Linux" ]]; then
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
