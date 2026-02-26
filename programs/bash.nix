{pkgs, ...}: {
  programs.bash = {
    enable = true;

    # ~/.profile
    #
    profileExtra = ''
      # Set OS type
      #
      OS="$(${pkgs.uutils-coreutils-noprefix}/bin/uname -s)"

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

      # Source files for environment setup
      #
      if [[ -d "$XDG_CONFIG_HOME"/bash/env.d ]]; then
        while read -r FILE; do
          source "$FILE"
        done < <(${pkgs.uutils-findutils}/bin/find -L "$XDG_CONFIG_HOME"/bash/env.d -type f -iname '*.sh' | ${pkgs.uutils-findutils}/bin/sort)
      fi

      # Set SHELL to the correct value
      #
      # We do this after the PATH has been fully configured to ensure
      # that we're catching the correct value
      #
      export SHELL="$(${pkgs.which}/bin/which bash)"
      if shopt -q login_shell; then
        if [ -x "$(${pkgs.uutils-coreutils-noprefix}/bin/realpath /bin)"/bash ]; then
          export SHELL="$(${pkgs.uutils-coreutils-noprefix}/bin/realpath /bin)"/bash
        elif [ -x "$(${pkgs.uutils-coreutils-noprefix}/bin/realpath /usr/bin)"/bash ]; then
          export SHELL="$(${pkgs.uutils-coreutils-noprefix}/bin/realpath /usr/bin)"/bash
        fi
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

      #### BEGIN: Repeat from ~/.profile to catch non-login shells ####

      # Set OS type
      #
      OS="$(${pkgs.uutils-coreutils-noprefix}/bin/uname -s)"

      # Make sure that Nix is set up
      #
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi

      # Source files for environment setup
      #
      if [[ -d "$XDG_CONFIG_HOME"/bash/env.d ]]; then
        while read -r FILE; do
          source "$FILE"
        done < <(${pkgs.uutils-findutils}/bin/find -L "$XDG_CONFIG_HOME"/bash/env.d -type f -iname '*.sh' | ${pkgs.uutils-coreutils-noprefix}/bin/sort)
      fi

      # Set SHELL to the correct value
      #
      export SHELL="$(${pkgs.which}/bin/which bash)"
      if shopt -q login_shell; then
        if [[ -x "$(${pkgs.uutils-coreutils-noprefix}/bin/realpath /bin)"/bash ]]; then
          export SHELL="$(${pkgs.uutils-coreutils-noprefix}/bin/realpath /bin)"/bash
        elif [[ -x "$(${pkgs.uutils-coreutils-noprefix}/bin/realpath /usr/bin)"/bash ]]; then
          export SHELL="$(${pkgs.uutils-coreutils-noprefix}/bin/realpath /usr/bin)"/bash
        fi
      fi

      ##### END: Repeat from ~/.profile to catch non-login shells #####
    '';

    historyControl = ["erasedups"];
    shellOptions = ["histappend"];
    enableCompletion = true;

    initExtra = ''
      # Exec fish
      #
      # We explicitly include this here, rather than as a file in
      # ~/.config/bash/rc.d, because we may exec fish
      #
      if [[ -n "$TERM" ]] && [[ -z "$VSCODE_RESOLVING_ENVIRONMENT" ]] &&
        [[ -z "$__EXEC_FISH" ]] && [[ -n "$(${pkgs.which}/bin/which fish)" ]] &&
        [[ ! -f "$HOME"/nofish ]] && [[ ! -f "$HOME"/nofish.txt ]] &&
        [[ ! -f /mnt/shared/nofish ]] && [[ ! -f /mnt/shared/nofish.txt ]] &&
        [[ ! -f /mnt/shared/Documents/nofish ]] && [[ ! -f /mnt/shared/Documents/nofish.txt ]] &&
        [[ ! -f "$HOME"/Documents/nofish ]] && [[ ! -f "$HOME"/Documents/nofish.txt ]]; then
        export __EXEC_FISH=1
        exec $(which fish)
      fi

      # Hack to get Bash to more agressively save its history
      #
      #   https://askubuntu.com/questions/67283/is-it-possible-to-make-writing-to-bash-history-immediate
      #
      PROMPT_COMMAND+=( "history -a" )

      # Convenience aliases
      #
      alias :e="$(${pkgs.which}/bin/which "$EDITOR")"
      alias :q=exit
      alias nvim="$(${pkgs.which}/bin/which "$EDITOR")"
      alias shutdown="/usr/bin/sudo /sbin/shutdown -h now"
      alias sudo="/usr/bin/sudo -E"
      alias vi="$(${pkgs.which}/bin/which "$EDITOR")"
      alias vim="$(${pkgs.which}/bin/which "$EDITOR")"

      # Source files for interactive shell setup
      #
      if [[ -d "$XDG_CONFIG_HOME"/bash/rc.d ]]; then
        while read -r FILE; do
          source "$FILE"
        done < <(${pkgs.uutils-findutils}/bin/find -L "$XDG_CONFIG_HOME"/bash/rc.d -type f -iname '*.sh' | ${pkgs.uutils-coreutils-noprefix}/bin/sort)
      fi
    '';

    enableVteIntegration = pkgs.stdenv.isLinux;
  };
}
