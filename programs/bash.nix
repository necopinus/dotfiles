{pkgs, ...}: {
  programs.bash = {
    enable = true;

    # ~/.profile
    #
    sessionVariables = {
      BAT_THEME = "ansi";
      DELTA_FEATURES = "+generic-dark-theme";
    };

    profileExtra = ''
      # Load system defaults if they exist
      #
      if [ -n "$BASH" ]; then
        if [ -f /etc/skel/.bash_profile ]; then
          . /etc/skel/.bash_profile
        fi
      else
        if [ -f /etc/skel/.profile ]; then
          . /etc/skel/.profile
        fi
      fi

      # Append Homebrew bin directory to PATH, since some GUI casks
      # install CLI binaries there
      #
      if [ -d /opt/homebrew/bin ]; then
        export PATH="$PATH:/opt/homebrew/bin"
      fi
    '';

    # ~/.bash_profile sources ~/.profile and then ~/.bashrc

    # ~/.bashrc
    #
    bashrcExtra = ''
      # Load system defaults if they exist
      #
      if [[ -f /etc/skel/.bashrc ]]; then
        source /etc/skel/.bashrc
      fi
    '';

    historyControl = ["erasedups"];
    shellOptions = ["histappend"];
    enableCompletion = true;

    initExtra = ''
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

      # Convenience aliases, unfortunately much too complex to set up
      # directly using home-manager's programs.bash.shellAliases
      #
      alias :e="$(which "$EDITOR")"
      alias :q=exit
      alias cat="$(which bat) -pp"
      alias ccat="$(which cat)"
      alias ddiff="$(which diff)"
      alias diff="$(which delta)"
      alias glow="$(which glow) -s dark"
      alias htop="$(which btm)"
      alias la="$(which eza) --classify=auto --color=auto --git --long --all"
      alias less="$(which bat)"
      alias ll="$(which eza) --classify=auto --color=auto --git --long"
      alias lless="$(which less)"
      alias lls="$(which ls)"
      alias ls="$(which eza) --classify=auto --color=auto --git"
      alias mmore="$(which more)"
      alias more="$(which bat)"
      alias nvim="$(which "$EDITOR")"
      alias rg="$(which rg) --color=auto"
      alias sudo="$(which sudo) -E"
      alias top="$(which btm)"
      alias ttop="$(which top)"
      alias vi="$(which "$EDITOR")"
      alias vim="$(which "$EDITOR")"

      if [[ "$(uname -s)" == "Linux" ]]; then
        alias shutdown="$(which sudo) /sbin/shutdown -h now"
      fi

      # Convenience function for launching graphical apps from the terminal
      #
      if [[ "$(uname -s)" == "Linux" ]]; then
        function xcv {
          nohup "$@" 2>/dev/null
        }
      fi
    '';

    enableVteIntegration = pkgs.stdenv.isLinux;
  };
}
