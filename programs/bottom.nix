{...}: {
  programs.bottom = {
    enable = true;

    settings = {
      styles = {
        widgets = {
          # Tweak suitable for all terminals
          #
          selected_border_color = "green";
          selected_text = {
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
