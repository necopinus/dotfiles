{...}: {
  xdg = {
    configFile."wezterm/wezterm.lua".source = ../artifacts/config/wezterm/wezterm.lua;
    terminal-exec = {
      settings = {
        default = [
          "org.wezfurlong.wezterm.desktop"
        ];
      };
    };
  };

  programs.wezterm = {
    enable = true;

    colorSchemes = {
      GruvboxLightMedium = {
        foreground = "#282828";
        background = "#fbf1c7";

        cursor_fg = "none";
        cursor_bg = "#7c6f64";
        cursor_border = "#7c6f64";
        compose_cursor = "#af3a03";

        selection_fg = "none";
        selection_bg = "#d5c4a1";

        ansi = [
          "#fbf1c7"
          "#cc241d"
          "#98971a"
          "#d79921"
          "#458588"
          "#b16286"
          "#689d6a"
          "#7c6f64"
        ];
        brights = [
          "#928374"
          "#9d0006"
          "#79740e"
          "#b57614"
          "#076678"
          "#8f3f71"
          "#427b58"
          "#3c3836"
        ];

        scrollbar_thumb = "#ebdbb2";
        split = "#7c6f64";

        copy_mode_active_highlight_fg = {Color = "#fbf1c7";};
        copy_mode_active_highlight_bg = {Color = "#7c6f64";};
        copy_mode_inactive_highlight_fg = {Color = "#3c3836";};
        copy_mode_inactive_highlight_bg = {Color = "#d5c4a1";};

        quick_select_label_fg = {Color = "#fbf1c7";};
        quick_select_label_bg = {Color = "#98971a";};
        quick_select_match_fg = {Color = "#fbf1c7";};
        quick_select_match_bg = {Color = "#d79921";};

        input_selector_label_fg = {Color = "#fbf1c7";};
        input_selector_label_bg = {Color = "#3c3836";};

        launcher_label_fg = {Color = "#fbf1c7";};
        launcher_label_bg = {Color = "#3c3836";};

        tab_bar = {
          background = "#fbf1c7";

          active_tab = {
            bg_color = "#a89984";
            fg_color = "#fbf1c7";
            intensity = "Bold";
          };

          inactive_tab = {
            bg_color = "#fbf1c7";
            fg_color = "#928374";
          };
          inactive_tab_hover = {
            bg_color = "#ebdbb2";
            fg_color = "#282828";
          };

          new_tab = {
            bg_color = "#fbf1c7";
            fg_color = "#504945";
          };
          new_tab_hover = {
            bg_color = "#458588";
            fg_color = "#fbf1c7";
            intensity = "Bold";
          };
        };
      };
    };
  };
}
