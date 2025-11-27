{...}: {
  programs.bottom = {
    enable = true;

    settings = {
      styles = {
        widgets = {
          # Gruvbox Light
          #
          selected_border_color = "yellow";
          selected_text = {
            color = "#fbf1c7";
            bg_color = "green";
          };

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
