{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.bottom = {
    enable = true;

    settings = {
      styles = {
        widgets = {
          # Default (tweaks)
          #
          selected_border_color = "green";
          selected_text = {
            fg_color = "white"; # TODO: Remove once the Android Terminal supports custom themes
            bg_color = "dark grey";
          };

          # Gruvbox Light
          #
          # selected_border_color = "yellow";
          # selected_text = {
          #   color = "#fbf1c7";
          #   bg_color = "green";
          # };

          # Gruvbox Material Light
          #
          # selected_border_color = "yellow";
          # selected_text = {
          #   color = "#f9f5d7";
          #   bg_color = "green"
          # };
        };
      };
    };
  };

  # Hide desktop entry
  #
  xdg.desktopEntries = lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
    "bottom" = {
      name = "bottom";
      noDisplay = true;
      settings = {
        Hidden = "true";
      };
    };
  };

  # Convenience aliases
  #
  xdg.configFile."bash/rc.d/bottom.sh" = {
    enable = config.programs.bash.enable;
    text = ''
      alias htop="${config.programs.bottom.package}/bin/btm --basic"
      alias top="${config.programs.bottom.package}/bin/btm --basic"
    '';
  };
  xdg.configFile."zsh/rc.d/bottom.sh" = {
    enable = config.programs.zsh.enable;
    text = ''
      alias htop="${config.programs.bottom.package}/bin/btm --basic"
      alias top="${config.programs.bottom.package}/bin/btm --basic"
    '';
  };
  xdg.configFile."fish/rc.d/bottom.fish" = {
    enable = config.programs.fish.enable;
    text = ''
      alias htop "${config.programs.bottom.package}/bin/btm --basic"
      alias top "${config.programs.bottom.package}/bin/btm --basic"
    '';
  };
}
