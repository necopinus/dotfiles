{pkgs, ...}: {
  programs.fish = {
    enable = true;

    # Run early for all shells
    #
    shellInit = ''
      # Set OS type
      #
      set OS $(${pkgs.uutils-coreutils-noprefix}/bin/uname -s)

      # Make sure that Nix is set up
      #
      if test -d /run/current-system/sw/bin
        fish_add_path /run/current-system/sw/bin
      end
      if test -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh; and test -z "$__ETC_PROFILE_NIX_SOURCED"
        ${pkgs.uutils-coreutils-noprefix}/bin/cat /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh | ${pkgs.babelfish}/bin/babelfish | source
      end
      if test -f $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh; and test -z "$__HM_SESS_VARS_SOURCED"
        ${pkgs.uutils-coreutils-noprefix}/bin/cat $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh | ${pkgs.babelfish}/bin/babelfish | source
      end

      # Append Homebrew bin directory to PATH, since some GUI casks
      # install CLI binaries there
      #
      if test -d /opt/homebrew/bin
        fish_add_path -a /opt/homebrew/bin
      end

      # Append ~/.local/bin to PATH, to allow for some work-around
      # symlinks
      #
      if test -d $HOME/.local/bin
        fish_add_path -a $HOME/.local/bin
      end

      # Make sure that environment defined in /etc/environment.d is
      # available
      #
      if test -d /etc/environment.d
        for FILE in (${pkgs.uutils-findutils}/bin/find -L /etc/environment.d -type f -iname '*.conf' | ${pkgs.uutils-coreutils-noprefix}/bin/sort)
          ${pkgs.uutils-coreutils-noprefix}/bin/cat "$FILE" | ${pkgs.babelfish}/bin/babelfish | source
        end
      end

      # Source files for local environment setup
      #
      if test -d "$XDG_CONFIG_HOME"/fish/env.d
        for FILE in (${pkgs.uutils-findutils}/bin/find -L "$XDG_CONFIG_HOME"/fish/env.d -type f -iname '*.fish' | ${pkgs.uutils-coreutils-noprefix}/bin/sort)
          source "$FILE"
        end
      end

      # Set SHELL to the correct value
      #
      # We do this after the PATH has been fully configured to ensure
      # that we're catching the correct value
      #
      set SHELL $(${pkgs.which}/bin/which fish)
    '';

    # If defined, run `loginShellInit` for login shells

    # Run for interactive shells
    #
    interactiveShellInit = ''
      # Convenience aliases
      #
      alias :e "$(${pkgs.which}/bin/which $EDITOR)"
      alias :q exit
      alias nvim "$(${pkgs.which}/bin/which $EDITOR)"
      alias shutdown "/usr/bin/sudo /sbin/shutdown -h now"
      alias sudo "/usr/bin/sudo -E"
      alias vi "$(${pkgs.which}/bin/which $EDITOR)"
      alias vim "$(${pkgs.which}/bin/which $EDITOR)"

      # Suppress welcome message
      #
      set -g fish_greeting

      # Source files for interactive shell setup
      #
      if test -d "$XDG_CONFIG_HOME"/fish/rc.d
        for FILE in (${pkgs.uutils-findutils}/bin/find -L "$XDG_CONFIG_HOME"/fish/rc.d -type f -iname '*.fish' | ${pkgs.uutils-coreutils-noprefix}/bin/sort)
          source "$FILE"
        end
      end
    '';

    # If defined, run `shellInitLast` last for all shells
  };
}
