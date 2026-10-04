{
  pkgs,
  config,
  ...
}: {
  imports = [
    ../../bundles/fish
  ];

  programs.herdr = {
    enable = true;
    settings = {
      onboarding = false;
      theme = {
        name = "gruvbox-light";
        auto_switch = false;
        #light_name = "gruvbox-light";
        #dark_name = "gruvbox";
        custom = {
          # Shared Gruvbox accent colors
          #
          mauve = "#b16286"; # purple
          green = "#98971a"; # green
          yellow = "#979921"; # yellow
          red = "#cc241d"; # red
          blue = "#458588"; # blue
          teal = "#689d6a"; # aqua
          peach = "#d65d0e"; # orange

          # Needs to match theme.name; remove if theme.auto_switch =
          # true
          #
          sidebar_bg = "#fbf1c7"; # bg0 || DEFAULT: "reset"
          active_row_bg = "#ebdbb2"; # bg1 || DEFAULT: "#f2e5bc" / bg0_s
          surface0 = "#d5c4a1"; # bg2 || DEFAULT: "#ebdbb2" / bg1
          surface1 = "#bdae93"; # bg3 || DEFAULT: "#d5c4a1" / bg2
          surface_dim = "#ebdbb2"; # bg1 || DEFAULT: "#f2e5bc" / bg0_s

          # Override Gruvbox theme colors for more consistency;
          # replicates defaults for the most part for reference
          #
          #light = {
          #  accent = "#076678"; # blue (dark)
          #  panel_bg = "#fbf1c7"; # bg0
          #  sidebar_bg = "#fbf1c7"; # bg0 || DEFAULT: "reset"
          #  active_row_bg = "#ebdbb2"; # bg1 || DEFAULT: "#f2e5bc" / bg0_s
          #  selection_bg = "#ebdbb2"; # bg1
          #  surface0 = "#d5c4a1"; # bg2 || DEFAULT: "#ebdbb2" / bg1
          #  surface1 = "#bdae93"; # bg3 || DEFAULT: "#d5c4a1" / bg2
          #  surface_dim = "#ebdbb2"; # bg1 || DEFAULT: "#f2e5bc" / bg0_s
          #  overlay0 = "#928374"; # gray
          #  overlay1 = "#7c6f64"; # fg4
          #  text = "#3c3836"; # fg1
          #  subtext0 = "#504945"; # fg2
          #  mauve = "#8f3f71"; # purple (dark)
          #  green = "#79740e"; # green (dark)
          #  yellow = "#b57614"; # yellow (dark)
          #  red = "#9d0006"; # red (dark)
          #  blue = "#076678"; # blue (dark)
          #  teal = "#427b58"; # aqua (dark)
          #  peach = "#af3a03"; # orange (dark)
          #};
          #dark = {
          #  accent = "#979921"; # yellow
          #  panel_bg = "#282828"; # bg0
          #  sidebar_bg = "#282828"; # bg0 || DEFAULT: "reset"
          #  active_row_bg = "#3c3836"; # bg1 || DEFAULT: "#32302f" / bg0_s
          #  selection_bg = "#3c3836"; # bg1 || DEFAULT: "#4b3f27" / ???
          #  surface0 = "#504945"; # bg2 || DEFAULT: "#3c3836" / bg1
          #  surface1 = "#665c54"; # bg3 || DEFAULT: "#504945" / bg2
          #  surface_dim = "#3c3836"; # bg1 || DEFAULT: "#282828" / bg0
          #  overlay0 = "#928374"; # gray
          #  overlay1 = "#a89984"; # fg4
          #  text = "#ebdbb2"; # fg1
          #  subtext0 = "#d5c4a1"; # fg2
          #  mauve = "#d3869b"; #purple (light)
          #  green = "#b8bb26"; # green (light)
          #  yellow = "#fabd2f"; # yellow (light)
          #  red = "#fb4934"; # red (light)
          #  blue = "#83a598"; # blue (light)
          #  teal = "#8ec07c"; # aqua (light)
          #  peach = "#fe8019"; # orange (light)
          #};
        };
      };
      terminal = {
        default_shell = "${config.programs.fish.package}/bin/fish";
      };
      update = {version_check = false;};
      keys = {
        next_tab = ["prefix+n" "prefix+right"];
        previous_tab = ["prefix+p" "prefix+left"];
      };
      ui = {
        mouse_scroll_lines = 1;
        status_indicators = "symbols";
        toast = {
          delivery = "system";
          clipboard = {position = "bottom-right";};
        };
      };
    };
  };

  # `terminal-notifier` is required by Herdr on macOS to enable delivery
  # of system notifications
  #
  home.packages = with pkgs;
    lib.optionals stdenv.hostPlatform.isDarwin [
      terminal-notifier
    ];

  # Auto-start Herdr, but only in Ghostty
  #
  # NOTE: The naming is funny because we want to be sure that this
  # always runs LAST
  #
  xdg.configFile."bash/rc.d/zz_herdr.sh" = {
    # Deliberately disabled, and deliberately still written in terms of
    # programs.bash.enable so that it parallels the equivalent blocks in
    # the other shell components. This allows the GIT_SIGNING_KEY to be
    # set correctly on exe.dev sessions.
    #
    enable = config.programs.bash.enable && false;
    text = ''
      if [[ $- == *i* ]] && [[ -z "$HERDR_ENV" ]] && [[ ! -f "$HOME/noherdr" ]] && [[ ! -f "$HOME/noherdr.txt" ]]; then
        ${config.programs.herdr.package}/bin/herdr && exit
      fi
    '';
  };
  # IMPORTANT: This is NOT a redundant copy of the bash snippet above.
  # The interactive-shell test differs: bash uses `[[ $- == *i* ]]`, zsh
  # uses `[[ -o interactive ]]`. Do not merge these two blocks.
  #
  xdg.configFile."zsh/rc.d/zz_herdr.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      if [[ -o interactive ]] && [[ -z "$HERDR_ENV" ]] && [[ ! -f "$HOME/noherdr" ]] && [[ ! -f "$HOME/noherdr.txt" ]]; then
        ${config.programs.herdr.package}/bin/herdr && exit
      fi
    '';
  };
  xdg.configFile."fish/rc.d/zz_herdr.fish" = {
    # Deliberately disabled, and deliberately still written in terms of
    # programs.fish.enable so that it parallels the equivalent blocks in
    # the other shell components. Herdr runs fish as its shell, so enabling
    # fish's Herdr integration risk Herdr launching Herdr -- an infinite
    # loop. Do not "simplify" this to `false`.
    #
    enable = config.programs.fish.enable && false;
    text = ''
      if status --is-interactive; and test -z "$HERDR_ENV"; and test ! -f $HOME/noherdr; and test ! -f $HOME/noherdr.txt
        ${config.programs.herdr.package}/bin/herdr && exit
      end
    '';
  };

  # Auto-start Herder, but ONLY on non-SSH connections, and only on
  # macOS (we auto-start Herdr on SSH connections)
  #
  # NOTE: The naming is funny because we want to be sure that this
  # always runs LAST
  #
  xdg.configFile."bash/rc.d/zz_tmux.sh" = {
    enable = config.programs.bash.enable && false;
    text = ''
      if [[ $- == *i* ]] && [[ -z "$HERDER_ENV" ]] && [[ -z "$SSH_TTY" ]] && [[ ! -f "$HOME/noherdr" ]] && [[ ! -f "$HOME/noherdr.txt" ]] && [[ ! -f /mnt/shared/Documents/noherdr ]] && [[ ! -f /mnt/shared/Documents/noherdr.txt ]]; then
        herdr && exit
      fi
    '';
  };
  xdg.configFile."zsh/rc.d/zz_tmux.zsh" = {
    enable = config.programs.zsh.enable && pkgs.stdenv.hostPlatform.isDarwin;
    text = ''
      if [[ -o interactive ]] && [[ -z "$HERDR_ENV" ]] && [[ -z "$SSH_TTY" ]] && [[ ! -f "$HOME/noherdr" ]] && [[ ! -f "$HOME/noherdr.txt" ]] && [[ ! -f /mnt/shared/Documents/noherdr ]] && [[ ! -f /mnt/shared/Documents/noherdr.txt ]]; then
        herdr && exit
      fi
    '';
  };
  xdg.configFile."fish/rc.d/zz_tmux.fish" = {
    enable = config.programs.fish.enable && false;
    text = ''
      if status --is-interactive; and test -z "$HERDR_ENV"; and test -z "$SSH_TTY"; and test ! -f $HOME/noherdr; and test ! -f $HOME/noherdr.txt; and test ! -f /mnt/shared/Documents/noherdr; and test ! -f /mnt/shared/Documents/noherdr.txt
        herdr && exit
      end
    '';
  };
}
