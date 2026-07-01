{pkgs, ...}: {
  programs.bash = {
    enable = true;
    package =
      if pkgs.stdenv.isDarwin
      then pkgs.bashInteractive # Bash on macOS is too old
      else null;

    # ~/.profile
    #
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

      # Append Homebrew bin directory to PATH, since some GUI casks
      # install CLI binaries there
      #
      if [ -d /opt/homebrew/bin ]; then
        export PATH="$PATH:/opt/homebrew/bin"
      fi

      # Append ~/.local/bin to PATH, as some systems will include
      # binaries here that we need to reference
      #
      if [ -d "$HOME"/.local/bin ]; then
        export PATH="$PATH:$HOME/.local/bin"
      fi

      # Make sure that environment defined in /etc/environment.d is
      # available
      #
      if [ -d /etc/environment.d ]; then
        for FILE in $(find -L /etc/environment.d -type f -iname '*.conf' | sort); do
          source "$FILE"
        done
      fi

      # Source files for local environment setup
      #
      if [ -d "$XDG_CONFIG_HOME"/bash/env.d ]; then
        for FILE in $(find -L "$XDG_CONFIG_HOME"/bash/env.d -type f -iname '*.sh' | sort); do
          source "$FILE"
        done
      fi

      # Set SHELL to the correct value
      #
      # We do this after the PATH has been fully configured to ensure
      # that we're catching the correct value
      #
      export SHELL="$(which bash)"
      if shopt -q login_shell; then
        if [ -x "$(realpath /bin)"/bash ]; then
          export SHELL="$(realpath /bin)"/bash
        elif [ -x "$(realpath /usr/bin)"/bash ]; then
          export SHELL="$(realpath /usr/bin)"/bash
        fi
      fi

      # Indicate that the profile has been sourced
      #
      export __PROFILE_SOURCED=1
    '';

    # ~/.bash_profile sources ~/.profile and then ~/.bashrc

    # ~/.bashrc
    #
    bashrcExtra = ''
      # Source ~/.profile, if necessary
      #
      if [[ -z "$__PROFILE_SOURCED" ]] && [[ -f "$HOME"/.profile ]]; then
        source "$HOME"/.profile
      fi

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
      # Hack to get Bash to more agressively save its history
      #
      #   https://askubuntu.com/questions/67283/is-it-possible-to-make-writing-to-bash-history-immediate
      #
      PROMPT_COMMAND+=( "history -a" )

      # Convenience aliases
      #
      alias :e=editor
      alias :q=exit

      # Source files for interactive shell setup
      #
      if [[ -d "$XDG_CONFIG_HOME"/bash/rc.d ]]; then
        for FILE in $(find -L "$XDG_CONFIG_HOME"/bash/rc.d -type f -iname '*.sh' | sort); do
          source "$FILE"
        done
      fi
    '';
  };
}
