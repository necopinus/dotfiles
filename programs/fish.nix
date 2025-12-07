{
  pkgs,
  lib,
  ...
}: {
  programs.fish = {
    enable = true;

    # Run early for all shells
    #
    shellInit = ''
      # Set OS type
      #
      set OS $(uname -s)

      # Set up Nix, if applicable
      #
      if test -d /run/current-system/sw/bin
        fish_add_path /run/current-system/sw/bin
      end

      if test -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        set -e __ETC_PROFILE_NIX_SOURCED
        cat /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh | ${pkgs.babelfish}/bin/babelfish | source
      end

      # Load $XDG_CONFIG_HOME/user-dirs.dirs when applicable
      #
      if test "$OS" = "Darwin"; and test -f "$XDG_CONFIG_HOME/user-dirs.dirs"
        cat $XDG_CONFIG_HOME/user-dirs.dirs | sed "s/^XDG_/export XDG_/" | ${pkgs.babelfish}/bin/babelfish | source
      end

      # Append Homebrew bin directory to PATH, since some GUI casks
      # install CLI binaries there
      #
      if test -d /opt/homebrew/bin
        fish_add_path --append /opt/homebrew/bin
      end
    '';

    # If defined, run `loginShellInit` for login shells

    # Run for interactive shells
    #
    interactiveShellInit = ''
      # Source various API keys into the environment
      #
      if test -f "$XDG_CONFIG_HOME"/api-keys.env.sh
        cat "$XDG_CONFIG_HOME"/api-keys.env.sh | ${pkgs.babelfish}/bin/babelfish | source
      end

      # Colorize man pages with bat
      #
      #   https://github.com/sharkdp/bat/issues/3053#issuecomment-2259573578
      #
      set -gx MANPAGER "sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -l man'"

      # Theme options
      #
      set -gx BAT_THEME "gruvbox-light"
      set -gx DELTA_FEATURES "+gruvbox-light"

      tweak_fish_colors gruvbox-light-medium

      # Convenience aliases
      #
      alias :e "$(which $EDITOR)"
      alias :q exit
      alias cat "$(which bat) -pp"
      alias diff "$(which delta)"
      alias glow "$(which glow) -s $XDG_CONFIG_HOME/glow/styles/gruvbox-light.json"
      alias htop "$(which btm) --basic"
      alias imgcat "$(which chafa)"
      alias la "$(which eza) --classify=auto --color=auto --icons=auto --group-directories-first --git --hyperlink --group --long --all"
      alias less "$(which bat)"
      alias ll "$(which eza) --classify=auto --color=auto --icons=auto --group-directories-first --git --hyperlink --group --long"
      alias ls "$(which eza) --classify=auto --color=auto --icons=auto --group-directories-first --git --hyperlink --group"
      alias more "$(which bat)"
      alias nvim "$(which $EDITOR)"
      alias rg "$(which rg) --color=auto"
      alias sudo "/usr/bin/sudo -E"
      alias top "$(which btm) --basic"
      alias vi "$(which $EDITOR)"
      alias vim "$(which $EDITOR)"

      # Hook fish postexec event to add a newline between prompts
      #
      #     https://stackoverflow.com/a/70644608
      #
      # For some reason this doesn't work if defined in `functions`, but
      # does work if defined in config.fish directly
      #
      function postexec_add_newline --on-event fish_postexec
        echo ""
      end

      # Suppress welcome message
      #
      set -g fish_greeting
    '';

    # If defined, run `shellInitLast` last for all shells

    functions =
      {
        # Additional theme/color tweaks
        #
        tweak_fish_colors = ''
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

        # Wrap git and gpg to make sure that the current terminal is
        # correctly set for gpg-agent
        #
        git = ''
          gpg-connect-agent UPDATESTARTUPTTY /bye > /dev/null
          set GIT_EXEC $(which git)
          $GIT_EXEC $argv
        '';
        gpg = ''
          gpg-connect-agent UPDATESTARTUPTTY /bye > /dev/null
          set GPG_EXEC $(which gpg)
          $GPG_EXEC $argv
        '';
      }
      // lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        # Convenience function for launching graphical apps from the terminal
        #
        xcv = "nohup $argv 2>/dev/null";
      };
  };
}
