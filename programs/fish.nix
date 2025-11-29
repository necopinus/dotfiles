{
  pkgs,
  lib,
  ...
}: {
  programs.fish = {
    enable = true;

    plugins = with pkgs.fishPlugins; [
      {
        name = "colored-man-pages";
        src = colored-man-pages.src;
      }
    ];

    # Run early for all shells
    #
    shellInit = ''
      # Set up Nix, if applicable
      #
      if test -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        set -e __ETC_PROFILE_NIX_SOURCED
        cat /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh | ${pkgs.babelfish}/bin/babelfish | source
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

      # Set LS_COLORS, as a surprising number of applications look wonky is
      # this variable isn't available
      #
      if test -n "$(which dircolors 2> /dev/null)"
        dircolors | ${pkgs.babelfish}/bin/babelfish | source
      end

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
      alias ccat "$(which cat)"
      alias ddiff "$(which diff)"
      alias diff "$(which delta)"
      alias glow "$(which glow) -s $XDG_CONFIG_HOME/glow/styles/gruvbox-light.json"
      alias htop "$(which top)"
      alias la "$(which eza) --classify=auto --color=auto --icons=auto --hyperlink --long --all"
      alias less "$(which bat)"
      alias ll "$(which eza) --classify=auto --color=auto --icons=auto --hyperlink --long"
      alias lless "$(which less)"
      alias lls "$(which ls)"
      alias ls "$(which eza) --classify=auto --color=auto --icons=auto --hyperlink"
      alias mmore "$(which more)"
      alias more "$(which bat)"
      alias nvim "$(which $EDITOR)"
      alias rg "$(which rg) --color=auto"
      alias top "$(which btm)"
      alias ttop "$(which top)"
      alias vi "$(which $EDITOR)"
      alias vim "$(which $EDITOR)"

      if test -n "$(which sudo 2> /dev/null)"
        alias sudo "$(which sudo) -E"

        if test "$(uname -s)" = Linux;
          and test -x /sbin/shutdown
          alias shutdown "$(which sudo) /sbin/shutdown -h now"
        end
      end

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
      }
      // lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        # Convenience function for launching graphical apps from the terminal
        #
        xcv = "nohup $argv 2>/dev/null";
      };
  };
}
