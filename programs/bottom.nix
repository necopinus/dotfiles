{pkgs, ...}: {
  xdg.dataFile."applications/bottom.desktop" = {
    enable = pkgs.stdenv.isLinux;
    source = ../artifacts/local/share/applications/hidden.desktop;
  };

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
}
