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
        fish_add_path --append /opt/homebrew/bin
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
      # Extra theme setup
      #
      # TODO: Uncomment once the Android Terminal supports custom themes
      #
      #tweak_fish_colors gruvbox-light-medium

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

    # Additional theme/color tweaks
    #
    functions."tweak_fish_colors" = ''
      if test $argv = "gruvbox-light-medium"
        set -g fish_color_autosuggestion a89984
        set -g fish_color_cancel --bold red
        set -g fish_color_command --bold cyan
        set -g fish_color_comment 928374
        set -g fish_color_end d65d0e
        set -g fish_color_error --bold red
        set -g fish_color_escape --bold magenta
        set -g fish_color_keyword --bold blue
        set -g fish_color_normal normal
        set -g fish_color_operator --bold green
        set -g fish_color_param normal
        set -g fish_color_quote --bold yellow
        set -g fish_color_redirection normal
        set -g fish_color_search_match --background f9f5d7
        set -g fish_color_selection normal --background d5c4a1
      else if test $argv = "gruvbox-material-light-hard"
        set -g fish_color_autosuggestion a89984
        set -g fish_color_cancel red
        set -g fish_color_command cyan
        set -g fish_color_comment 928374
        set -g fish_color_end c35e0a
        set -g fish_color_error red
        set -g fish_color_escape magenta
        set -g fish_color_keyword blue
        set -g fish_color_normal normal
        set -g fish_color_operator green
        set -g fish_color_param normal
        set -g fish_color_quote yellow
        set -g fish_color_redirection normal
        set -g fish_color_search_match --background f9eabf
        set -g fish_color_selection normal --background f2e5bc
      end
    '';
  };
}
