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
      # Set OS type
      #
      OS="$(uname -s)"

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

      # Make sure that Nix is set up
      #
      if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi
      if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && [ -z "$__HM_SESS_VARS_SOURCED" ]; then
        source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi

      # Load $XDG_CONFIG_HOME/user-dirs.dirs when applicable
      #
      if [ "$OS" == "Darwin" ] && [ -f "$XDG_CONFIG_HOME/user-dirs.dirs" ]; then
        eval "$(cat "$XDG_CONFIG_HOME/user-dirs.dirs" | sed "s/^XDG_/export XDG_/")"
      fi

      # Append Homebrew bin directory to PATH, since some GUI casks
      # install CLI binaries there
      #
      if [ -d /opt/homebrew/bin ]; then
        export PATH="$PATH:/opt/homebrew/bin"
      fi

      # Set SHELL to the correct value
      #
      # We do this after the PATH has been fully configured to ensure
      # that we're catching the correct value
      #
      if shopt -q login_shell; then
        if [ -x "$(realpath /bin)"/bash ]; then
          export SHELL="$(realpath /bin)"/bash
        elif [ -x "$(realpath /usr/bin)"/bash ]; then
          export SHELL="$(realpath /usr/bin)"/bash
        else
          export SHELL="$(which bash)"
        fi
      else
        export SHELL="$(which bash)"
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

      # Make sure that Nix is set up
      #
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi
    '';

    historyControl = ["erasedups"];
    shellOptions = ["histappend"];
    enableCompletion = true;

    initExtra = ''
      # Set OS type
      #
      OS="$(uname -s)"

      # Set SHELL to the correct value
      #
      # We do this after the PATH has been fully configured to ensure
      # that we're catching the correct value
      #
      if shopt -q login_shell; then
        if [ -x "$(realpath /bin)"/bash ]; then
          export SHELL="$(realpath /bin)"/bash
        elif [ -x "$(realpath /usr/bin)"/bash ]; then
          export SHELL="$(realpath /usr/bin)"/bash
        else
          export SHELL="$(which bash)"
        fi
      else
        export SHELL="$(which bash)"
      fi

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

      # Colorize man pages with batman, and then some
      #
      eval "$(batman --export-env)"
      eval "$(batpipe)"

      # Convenience aliases, unfortunately much too complex to set up
      # directly using home-manager's programs.bash.shellAliases
      #
      alias :e="$(which "$EDITOR")"
      alias :q=exit
      alias cat="$(which bat) -pp"
      alias diff="$(which delta)"
      alias glow="$(which glow) -s dark"
      alias htop="$(which btm) --basic"
      alias imgcat="$(which chafa)"
      alias jq="$(which jaq)"
      alias la="$(which eza) --classify=auto --color=auto --group-directories-first --git --group --long --all"
      alias less="$(which bat)"
      alias ll="$(which eza) --classify=auto --color=auto --group-directories-first --git --group --long"
      alias ls="$(which eza) --classify=auto --color=auto --group-directories-first --git --group"
      alias more="$(which bat)"
      alias nvim="$(which "$EDITOR")"
      alias prettycat="$(which prettybat)"
      alias rg="$(which batgrep)"
      alias sudo="/usr/bin/sudo -E"
      alias top="$(which btm) --basic"
      alias vi="$(which "$EDITOR")"
      alias vim="$(which "$EDITOR")"
      alias watch="$(which batwatch)"
      alias yq="$(which jaq)"

      # Alias LXQt session startup
      #
      if [[ "$OS" == "Linux" ]]; then
        alias start-desktop="$(which startlxqtwayland)"
        alias startlxqt="$(which startlxqtwayland)"
      fi

      # The Android Debian VM is surprisingly fragile, so we want to
      # do a shutdown rather than just exiting the last session
      #
      if [[ "$OS" == "Linux" ]]; then
        alias shutdown="/usr/bin/sudo /sbin/shutdown -h now"
      fi

      # Wrap man/batman to supress readlink errors
      #
      function man {
        MAN_EXEC="$(which man)"
        $MAN_EXEC "$@" 2> /dev/null
      }
      function batman {
        BATMAN_EXEC="$(which batman)"
        $BATMAN_EXEC "$@" 2> /dev/null
      }

      # Convenience function for launching graphical apps from the terminal
      #
      if [[ "$OS" == "Linux" ]]; then
        function xcv {
          nohup "$@" 2>/dev/null
        }
      fi

      # Hack to get Bash to more agressively save its history
      #
      #   https://askubuntu.com/questions/67283/is-it-possible-to-make-writing-to-bash-history-immediate
      #
      PROMPT_COMMAND+=( "history -a" )
    '';

    enableVteIntegration = pkgs.stdenv.isLinux;
  };
}
